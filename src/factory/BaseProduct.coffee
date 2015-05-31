Module = require '../Module'

class BaseProduct extends Module
  ###
  Factory product
  ###

  constructor: (browser, webdriver, args) ->
    ###
    Constructor

    @param {Browser} browser-class instance
    @param {webdriver} webdriver base class
    @param {array} Additional arguments for BaseProduct.init() method
    ###
    @browser = browser
    @webdriver = webdriver

    @init.apply(this, args)


  init: ->
    ###
    Initializing
    ###


  ###
  Method-proxies from browser-instance for advanced readability in all test-products
  ###
  driver: (args...) -> @browser.driver.apply(@browser, args)
  pageObject: (args...) -> @browser.pageObject.apply(@browser, args)
  helper: (args...) -> @browser.helper.apply(@browser, args)
  element: (args...) -> @browser.element.apply(@browser, args)
  go: (args...) -> @browser.go.apply(@browser, args)
  sleep: (args...) -> @browser.sleep.apply(@browser, args)
  refresh: (args...) -> @browser.refresh.apply(@browser, args)
  getCurrentUrl: (args...) -> @browser.getCurrentUrl.apply(@browser, args)
  forceForeground: (args...) -> @browser.forceForeground.apply(@browser, args)
  takeScreenshot: (args...) -> @browser.takeScreenshot.apply(@browser, args)



module.exports = BaseProduct