webdriver         = require './webdriver'
PathResolver      = require './utils/PathResolver'
fs                = require 'fs.extra'
path              = require 'path'
_                 = require 'lodash'

Browser           = require './Browser'

# Classes for inheriting in concrete test's implementation
PageObject        = require './page-objects/PageObject'
Form              = require './page-objects/Form'
TestHelper        = require './helpers/TestHelper'


###
Private properties and methods
###

_config = null
_testName = null

_currentContext = null
_currentAbsolutePath = null
_currentRelativePath = null

_uncaughtExceptionSet = false

_browserInstances = []
_pathResolver = new PathResolver


_loadConfig = ->
  ###
  Reads test config

  @return {object}
  ###
  stofConfig = require('./config')
  defaultConfig = self.loadFile('/config//defaultConfig', '', false)
  _.merge(stofConfig, defaultConfig)
  _config = self.loadFile('/config//config', '', false)
  _config = _.merge(stofConfig, _config)
  _config


_parseTestRootDir = ->
  ###
  Finds test root dir path in command line arguments and process environment

  @return {String}
  ###
  testRootDir = null
  process.argv.forEach (value) ->
    testRootDir = value.substr('--stof-root-dir='.length) if value.indexOf('--stof-root-dir=') == 0

  return testRootDir if testRootDir?

  if not process.env.STOF_ROOT_DIR?
    throw new Error('Please specify command line argument --stof-root-dir or environment variable STOF_ROOT_DIR')

  process.env.STOF_ROOT_DIR


_parseTargetDir = ->
  ###
  Finds test target dir path in command line arguments and process environment.
  By default returns 'target'

  @return {String}
  ###
  testTargetDir = null
  process.argv.forEach (value) ->
    testTargetDir = value.substr('--stof-target-dir='.length) if value.indexOf('--stof-target-dir=') == 0

  return testTargetDir if testTargetDir?
  return process.env.STOF_TARGET_DIR if process.env.STOF_TARGET_DIR?

  'target'


_prepareStackTrace = (stack) ->
  ###
  Cuts useless information from stacktrace

  @param {String} raw stacktrace

  @return {String}
  ###
  # Try to remove non-async stacktrace
  asyncSeparator = '==== async task ===='
  asyncTaskPos = stack.indexOf(asyncSeparator)
  if stack and asyncTaskPos != -1
    stack = stack.substring(asyncTaskPos + asyncSeparator.length)

  # Remove stacktrace higher than spec, and deeper than stof.webdriver
  preparedStack = stack.substring(0, stack.indexOf('\n') + 1)
  write = false
  for num, line of stack.split(/\n/)
    preparedStack += line + '\n' if write
    write = true if line.match('stof')
    break if line.match(/specs/)

  preparedStack


self =
  ###
  Public methods
  ###
  getRootBrowser: ->
    ###
    Gets and returns root browser's instance.
    Root browser always exists.

    @return {Browser} — main browser instance
    ###
    _browserInstances[0]


  newWindow: (capabilities) ->
    ###
    Returns new Browser instance. It will have independent driver (and window).
    It is possible to pass capabilities as an hash-object to explicitly define browser or platform,
    which new browser windows should be in.

    @param {Object} Hash table with fields [browser, platform]

    @return {Browser}
    ###
    browserInstance = new Browser

    if capabilities
      desiredCapabilities = _.merge(browserInstance.getDesiredCapabilities(), capabilities)
      browserInstance.setDesiredCapabilities(desiredCapabilities)

    self.addBrowserInstance(browserInstance)
    browserInstance


  addBrowserInstance: (browserInstance) ->
    ###
    Adds browser to list of active windows.
    This is needed to be able to take screenshots, stores logs and quit from all windows, used in a test

    @param {Browser} browser instance to add
    ###
    key = _browserInstances.length
    _browserInstances[key] = browserInstance
    browserInstance.browserInstanceKey = key


  removeBrowserInstance: (key) ->
    ###
    Removes browser instance from instance array.
    Root browser (with key = 0) instance cannot be removed

    @param {int} browser instance key
    ###
    delete _browserInstances[key] if key != 0


  resolvePath: (directory, subFolderInBundle = '') ->
    ###
    Resolves pseudo path to product

    @param {String} pseudo-path to the class in BaseFactory.require() notation
    @param {String} Additional path inside the bundle

    @return {String}
    ###
    {bundle, relativePath} = _pathResolver.parsePathRaw(directory, _currentRelativePath)
    subFolderInBundle = subFolderInBundle.trimRight('/') + '/' if subFolderInBundle

    "#{_currentAbsolutePath}/#{bundle}/#{subFolderInBundle}#{relativePath}"


  loadFile: (directory, subFolderInBundle = '', strict = true) ->
    ###
    Requires file in path

    @param {String} pseudo-path to the class in BaseFactory.require() notation
    @param {String} Additional path inside the bundle

    @return {object}
    ###
    directory = self.resolvePath(directory, subFolderInBundle)
    if strict or fs.existsSync("#{directory}.js")
      require(directory)
    else
      {}


  getConfigValue: (propertyPath) ->
    ###
    Returns config property

    @param {String} Point separated path to property. For example, stof.browser will return config[stof][browser] property value

    @return {String|object} Property value
    ###
    _loadConfig() if not _config?
    directory = propertyPath.split(/\./)
    value = _config
    for part in directory
      value = value[part]
      break if not value
    value


  defineContext: (filename, updateTestName = true) ->
    ###
    Defines current executed file path names. It determines absolute and relative path to bundle.

    @param {String} Current executed file name. Usually __filename value
    ###
    _currentContext = filename

    directory = path.dirname(filename)
    pathParts = directory.split(/(?:specs|page-objects|helpers)/)
    directory = pathParts[0] if pathParts.length == 2

    testRootDir = _parseTestRootDir()

    ###
      coffee script test spec can be specified. But test objects and helpers must be included from target dir.
      Let's handle it
    ###
    targetDir = _parseTargetDir()
    splitPathDir = testRootDir
    splitPathDir = splitPathDir.replace(targetDir, '')  if splitPathDir.indexOf(targetDir) != -1
    pathParts = directory.split(splitPathDir)

    _currentAbsolutePath = "#{pathParts[0]}/#{testRootDir}"
    _currentAbsolutePath = _currentAbsolutePath.trimRight('/')
    _currentRelativePath = pathParts[1]

    if updateTestName
      filename = path.basename(filename, '.js')
      _testName = filename

      self.defineUncaughtExceptionHandler()


  getCurrentContext: ->
    ###
    Returns current context, i.e. current test file name
    ###
    _currentContext


  closeAllWindows: ->
    ###
    Closes all browser windows attached to Stof instance
    ###
    promises = []
    for key, browser of _browserInstances
      if browser?
        promises.push(browser.quit())
      else
        throw e

    webdriver.promise.all(promises)


  defineUncaughtExceptionHandler: () ->
    ###
    Sets global uncaughtException handler

    @param {String} Current executed file name. Usually __filename value
    ###
    return if _uncaughtExceptionSet
    _uncaughtExceptionSet = true

    # Uncaught exception handler
    uncaughtException = (e) =>
      webdriver.promise.controlFlow().removeListener('uncaughtException', uncaughtException)
      _uncaughtExceptionSet = false

      fs.mkdirpSync(getConfigValue('stof.screenshotsDir'))
      fs.mkdirpSync(getConfigValue('stof.logsDir'))

      e.stack = _prepareStackTrace(e.stack)

      promises = []
      for key, browser of _browserInstances
        if browser?
          screenshotKey = browser.browserInstanceKey
          filename = _testName + screenshotKey
          promises.push(browser.takeScreenshot(filename))
          promises.push(browser.getAndSaveLogs('browser.txt'))
          promises.push(browser.dumpDomContents("#{filename}_dom"))
          promises.push(browser.quit())
        else
          throw e

      webdriver.promise.all(promises).then ->
        throw e

    # Bind uncaught exception handler
    webdriver.promise.controlFlow().on('uncaughtException', uncaughtException)


  done: ->
    ###
    Returns last queued promise in selenium webdriver control flow

    @return {webdriver.Promise}
    ###
    @getRootBrowser().done()


  promise: ->
    ###
    Returns webdriver's promise library

    Sample usage (written on CoffeeScript)
      deferred = stof.promise().defer()
      doSomeThing ->
        deferred.fulfill()
      deferred.promise
    ###
    webdriver.promise


self.newWindow()


module.exports = self