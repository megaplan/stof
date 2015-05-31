# Classes for inheriting in concrete test's implementation
PageObject        = require './page-objects/PageObject'
Form              = require './page-objects/Form'
TestHelper        = require './helpers/TestHelper'


# Get Stof singleton
stof = require './stof'

# and export it to globals
# it is required for Browsers, to gain access to root browser instance.
global.stof = stof

# Export stof's global methods
global.getConfigValue = -> stof.getConfigValue.apply(stof, arguments)
global.newWindow = -> stof.newWindow.apply(stof, arguments)

# Export root browser's methods to globals, for readibility in
rootBrowser = stof.getRootBrowser()
global.helper = -> rootBrowser.helper.apply(rootBrowser, arguments)
global.helperClass = -> rootBrowser.helperClass.apply(rootBrowser, arguments)
global.pageObject = -> rootBrowser.pageObject.apply(rootBrowser, arguments)
global.pageObjectClass = -> rootBrowser.pageObjectClass.apply(rootBrowser, arguments)
global.element = -> rootBrowser.element.apply(rootBrowser, arguments)
global.go = -> rootBrowser.go.apply(rootBrowser, arguments)
global.sleep = -> rootBrowser.sleep.apply(rootBrowser, arguments)
global.refresh = -> rootBrowser.refresh.apply(rootBrowser, arguments)
global.getCurrentUrl = -> rootBrowser.getCurrentUrl.apply(rootBrowser, arguments)
global.forceForeground = -> rootBrowser.forceForeground.apply(rootBrowser, arguments)
global.takeScreenshot = -> rootBrowser.takeScreenshot.apply(rootBrowser, arguments)
global.step = (msg) ->
  rootBrowser.driver.call(rootBrowser).controlFlow().execute -> console.log(msg)

# Export base classes to globals, for handsome inheriting without requisition to call 'require()'
global.PageObject = PageObject
global.Form = Form
global.TestHelper = TestHelper