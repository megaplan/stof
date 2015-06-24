webdriver         = require './webdriver'
PageObjectFactory = require './factory/PageObjectFactory'
ElementFactory    = require './factory/ElementFactory'
HelperFactory     = require './factory/HelperFactory'
WebDriverFactory  = require './factory/WebDriverFactory'

fs                = require 'fs'
_                 = require 'lodash'


class Browser

  driverInstance: null
  browserInstancesKey: null

  pageObjectFactory: null
  elementFactory: null
  helperFactory: null

  desiredCapabilities:
    browser: null
    platform: null

  constructor: ->
    @pageObjectFactory = new PageObjectFactory(this)
    @elementFactory = new ElementFactory(this)
    @helperFactory = new HelperFactory(this)
    this


  driver: ->
    ###
    Returns webdriver instance
    ###
    if not @driverInstance?
      @driverInstance = WebDriverFactory.createWebDriver(
        @desiredCapabilities['browser'],
        @desiredCapabilities['platform']
      )
    @driverInstance


  pageObject: (directory, waitReady = true, containerSelector = null) ->
    ###
    Creates page-object using factory

    @param {String} pseudo-path to the class in BaseFactory.require() notation
    @param {boolean} wait until page-object is ready
    @param {String} Container that holds the pageobject

    @return {PageObject}
    ###
    pObject = @pageObjectFactory.produce(stof, directory, webdriver, containerSelector)
    pObject.ready() if waitReady
    pObject


  pageObjectClass: (directory) ->
    ###
    Returns page-object definition

    @param {String} pseudo-path to the class in BaseFactory.require() notation

    @return {Object}
    ###
    @pageObjectFactory.require(stof, directory)


  helper: (helperPath, args...) ->
    ###
    Creates helper

    @param {String} pseudo-path to the class in BaseFactory.require() notation
    @param {splat} custom arguments

    @return {TestHelper}
    ###
    @helperFactory.produce(stof, helperPath, webdriver, args...)


  helperClass: (helperPath) ->
    ###
    Returns helper definition

    @param {String} pseudo-path to the class in BaseFactory.require() notation

    @return {Object}
    ###
    @helperFactory.require(stof, helperPath, webdriver)


  element: (selector, parentElement = null, elementDescription = '') ->
    ###
    Creates WebElement wrapper

    @param {(String|webdriver.By.Hash)} Element locator
    @param {WebElement} Parent element
    @param {String} Human readable element description which is used in error messages

    @return {TestHelper}
    ###
    @elementFactory.produce(stof, 'WebElement', webdriver, selector, parentElement, elementDescription)


  sleep: (ms) ->
    ###
    Proxy method for webdriver.WebDriver.sleep
    ###
    @driver().sleep(ms)


  refresh: ->
    ###
    Proxy method for webdriver.WebDriver.Navigation.refresh
    ###
    @driver().navigate().refresh()


  takeScreenshot: (filename, dir = getConfigValue('stof.screenshotsDir')) ->
    ###
    Takes screenshot from current stof instances driver
    and saves it to screenshotsDir with filename as passed argument

    @param {String} filename of a new screenshot. If file with the same name exists, it will be overwritten.
    @param {String} Path to dir where screenshot should be stored
    ###
    @driver().takeScreenshot().then (data) =>
      screenshotName = "#{dir}/#{filename}.png"
      fs.writeFileSync(screenshotName, data, 'base64')
    , (screenshotE) ->
      console.log "Error while taking screenshot into file #{filename}:", screenshotE


  getAndSaveLogs: (filename, dir = getConfigValue('stof.logsDir')) ->
    ###
    Gets logs from browser window attached to passed stofInstance's driver
    and saves them to logsDir

    @param {Stof} stof instance, to save browser logs from
    ###
    logs = new webdriver.WebDriver.Logs(@driver())
    logs.get(webdriver.logging.Type.BROWSER).then (result) =>
      logToWrite = ''

      # parse all objects from browser console output
      for obj in result
        if not @filterLogMessage(obj.message)
          date = new Date(obj.timestamp).toISOString().replace(/T/, ' ').replace(/\..+/, '')

          message = obj.message
          # Remove useless "Console.js" url from stack trace
          message = message.replace /\S+\/cord\/core\/Console.js\S+ \d+:\d+\s+(at )?/, ''

          logToWrite += "\n#{date}: #{message}"

      fs.writeFileSync("#{dir}/#{filename}", logToWrite, {flag: 'a'})
      fs.writeFileSync("#{dir}/#{filename}.html", @logsToHtml(logToWrite), {flag: 'a'})

    , (logsE) ->
      console.log "Error while saving logs: ", logsE


  filterLogMessage: (message) ->
    ###
    Filters messages that should not appear in log
    ###
    return true if message.match /"source":"console-api".*"functionName":"self.clear"/
    false

  logsToHtml: (text) ->
    text = "<style>.date {color:Gray; margin-right:20px} .url {color:darkblue} .trace {opacity:0.7; font-size:80%}</style>#{text}"
    text = text.replace /(\d+-\d+-\d+ \d+:\d+:\d+): (https?:\S+), ([^\n]+)/g, "<span class=date>$1</span>$3<span class=trace>$2</span>"
    text = text.replace /(\d+-\d+-\d+ \d+:\d+:\d+): (https?:\S+)( [0-9:]+)? ([^\n]+)/g, "<span class=date>$1</span>$4<span class=trace>$2 $3</span>"
    text = text.replace /(\d+-\d+-\d+ \d+:\d+:\d+): ([^\n]+)/g, "<span class=date>$1</span>$2"
    text = text.replace /\n(\s+at .+(\/[\w-]+\/[\w\.-]+))(\?.*)?(:\d+)(:\d+)(.*)/g, "\n<span class=trace>$1 <input value=\"$2$4$5\" onclick=\"select()\" size=\"18\"/>$6</span>"
    text = text.replace /(-{5,})/g, "<span class=trace>$1</span>"
    text = text.replace /(https?:\S+)/g, '<a href="$1">$1</a>'
    text = text.replace /\n/g, "<br>\n"
    text


  dumpDomContents: (filename) ->
    ###
    Gets current DOM tree contents and saves to file

    @param {String} filename. If file with the same name exists, it will be overwritten.
    ###
    @driver().executeScript("return document.getElementsByTagName('html')[0].outerHTML;").then (html) ->
      dir = getConfigValue('stof.logsDir')
      domDumpName = "#{dir}/#{filename}.txt"
      fs.writeFileSync(domDumpName, html, 'utf8')
    , (domE) ->
      console.log "Error while taking DOM content into file #{filename}:", domE


  getCurrentUrl: ->
    ###
    Proxy method for webdriver.WebDriver.getCurrentUrl()
    ###
    @driver().getCurrentUrl()


  addCookie: (name, value) ->
    ###
    Adds cookie in browser.

    @param {String} Cookie name
    @param {String} Cookie value
    ###
    @driver().manage().addCookie(name, value)


  deleteCookie: (name) ->
    ###
    Removes cookie by name

    @param {String} Cookie name
    ###
    @driver().manage().deleteCookie(name)


  getCookie: (name) ->
    ###
    Returns cookie by name

    @param {String} Cookie name

    @return {webdriver.promise.Promise}
    ###
    @driver().manage().getCookie(name)


  go: (url = '/') ->
    ###
    Navigate browser to URL consider to config property <applicationUrl>

    @param {String} Url to open
    ###
    if not url.match /^https?:\/\//
      # relative URL
      proto = if stof.getConfigValue('stof.useSsl') then 'https' else 'http'
      fullUrl = proto + '://' + stof.getConfigValue('stof.applicationHost')
      port = stof.getConfigValue('stof.port')
      fullUrl += ':' + port if port
      url = fullUrl + url

    @driver().get(url)

    if waitFor = getConfigValue('stof.waitAfterReloadSelector')
      @element(waitFor).ready()


  forceForeground: ->
    ###
    Returns focus to current window
    ###
    stof.getRootBrowser().driver().switchTo().window(@driver().getWindowHandle())


  quit: ->
    ###
    Closes driver
    ###
    @driver().quit().then =>
      @driverInstance = null
      stof.removeBrowserInstance(@browserInstanceKey)
    , (e) =>
      @driverInstance = null
      stof.removeBrowserInstance(@browserInstanceKey)
      throw e


  setDesiredCapabilities: (desiredCapabilities) ->
    ###
    Setter for desiredCapabilities field
    ###
    @desiredCapabilities = desiredCapabilities


  getDesiredCapabilities: ->
    ###
    Getter for desiredCapabilities field
    ###
    @desiredCapabilities


  done: ->
    ###
    Returns last queued promise in selenium webdriver control flow

    @return {webdriver.Promise}
    ###
    @schedule(_.noop())


  schedule: (fn) ->
    ###
    Schedules a command to execute a custom function in webdriver control flow

    @param {function(): T|webdriver.promise.Promise[T]}
    ###
    @driver()['call'](fn)


module.exports = Browser