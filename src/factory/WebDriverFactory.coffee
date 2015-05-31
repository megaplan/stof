webdriver      = require '../webdriver'
SeleniumServer = require('selenium-webdriver/remote').SeleniumServer
fs             = require 'fs.extra'


class WebDriverFactory
  ###
  Factory for WebDriver
  ###

  createWebDriver: (browser = getConfigValue('stof.browser'), platform = getConfigValue('stof.os')) ->
    ###
    Creates WebDriver instance using settings from defaultConfig.

    @return {webdriver.WebDriver}
    ###
    capabilities = webdriver.Capabilities[browser].call()
    capabilities.set(webdriver.Capability.PLATFORM, platform) if platform
    chromeOptions = getConfigValue('stof.chromeOptions')
    capabilities.set('chromeOptions', chromeOptions) if browser == 'chrome' and chromeOptions

    builder = new webdriver.Builder

    # Start server if path to jar is specified
    pathToSeleniumJar = getConfigValue('stof.selenium.pathToJar')
    if pathToSeleniumJar
      if not fs.existsSync(pathToSeleniumJar)
        throw new Error("#{pathToSeleniumJar} does not exist")

      server = new SeleniumServer(pathToSeleniumJar, {
        port: getConfigValue('stof.selenium.port')
      })
      server.start(getConfigValue('stof.selenium.startTimeout'))
      serverAddress = server.address()
    else
      serverAddress = getConfigValue('stof.selenium.server')

    builder.usingServer(serverAddress) if serverAddress

    # Build the driver
    driver = builder.withCapabilities(capabilities).build()

    driver.manage().window().setSize(getConfigValue('stof.windowWidth'), getConfigValue('stof.windowHeight'))
    driver



module.exports = new WebDriverFactory
