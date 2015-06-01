webdriver = require 'selenium-webdriver'


webdriver.WebDriver::waitForElementPresent = (locator, waitForDisplayed = true, timeoutMultiplier = 1, elementDescription = '') ->
  ###
  Waits until element exists in DOM tree and until it is visible (optional)

  @param {webdriver.Locator} The locator to use
  @param {boolean} should it also waits for element visibility
  @param {int} Multiplier for default waiting timeout
  @param {String} Human readable element description which is used in error messages

  @return {webdriver.promise.Promise}
  ###
  elementDescription = if elementDescription then "#{locator.value} (#{elementDescription})" else locator.value

  # Copy stack for proper error message
  stack = (new Error).stack
  @getCurrentUrl().then (url) =>
    errMsg = "Element '#{elementDescription}' cannot be found on page #{url}"
    promises = []
    wait = @wait(
      => @isElementPresent(locator),
      getConfigValue('stof.elementWait') * timeoutMultiplier,
      errMsg
    )
    .thenCatch (err) ->
      console.error errMsg, stack
      throw err
    promises.push wait

    if waitForDisplayed
      errMsg = "Element '#{elementDescription}' isn't displayed on page #{url}"
      promises.push @wait(
        => @findElement(locator).isDisplayed().then undefined, (err) ->
          false
        ,
        getConfigValue('stof.elementWait') * timeoutMultiplier,
        errMsg
      ).thenCatch (err) ->
        console.error errMsg, stack
        throw err

    webdriver.promise.all(promises)


webdriver.WebElement::waitForElementPresent = (locator, waitForDisplayed = true, timeoutMultiplier = 1, elementDescription = '') ->
  ###
  Waits until element exists in current element children

  @param {webdriver.Locator} The locator to use
  @param {boolean} should it also waits for element visibility
  @param {int} Multiplier for default waiting timeout
  @param {String} Human readable element description which is used in error messages

  @return {webdriver.promise.Promise}
  ###
  elementDescription = if elementDescription then "#{locator.value} (#{elementDescription})" else locator.value

  # Copy stack for proper error message
  stack = (new Error).stack
  driver = @getDriver()
  driver.getCurrentUrl().then (url) =>
    errMsg = "Element '#{elementDescription}' cannot be found on page #{url}"
    promises = []
    wait = driver.wait(
      => @isElementPresent(locator),
      getConfigValue('stof.elementWait') * timeoutMultiplier,
      errMsg
    )
    .thenCatch (err) ->
      console.error errMsg, stack
      throw err

    promises.push wait

    if waitForDisplayed
      errMsg = "Element '#{elementDescription}' isn't displayed on page #{url}"
      promises.push driver.wait(
        => @findElement(locator).isDisplayed().then undefined, ->
          false
        ,
        getConfigValue('stof.elementWait') * timeoutMultiplier,
        errMsg
      ).thenCatch (err) ->
        console.error errMsg, stack
        throw err

    webdriver.promise.all(promises)


webdriver.WebDriver::waitForElementNotPresent = (locator, elementDescription = '') ->
  ###
  Waits until element does not exist in DOM tree

  @param {webdriver.Locator} The locator to use
  @param {String} Human readable element description which is used in error messages

  @return {webdriver.promise.Promise}
  ###
  elementDescription = if elementDescription then "#{locator.value} (#{elementDescription})" else locator.value

  # Copy stack for proper error message
  stack = (new Error).stack
  @getCurrentUrl().then (url) =>
    errMsg = "Element '#{elementDescription}' is still present on page #{url}"
    @wait(
      => @isElementPresent(locator).then (value) ->
        not value
      ,
      getConfigValue('stof.elementWait'),
      errMsg
    ).thenCatch (err) ->
      console.error errMsg, stack
      throw err


webdriver.WebElement::waitForElementNotPresent = (locator, elementDescription = '') ->
  ###
  Waits until element does not exist in DOM tree
  @param {webdriver.Locator} The locator to use
  @param {String} Human readable element description which is used in error messages

  @return {webdriver.promise.Promise}
  ###
  elementDescription = if elementDescription then "#{locator.value} (#{elementDescription})" else locator.value

  # Copy stack for proper error message
  stack = (new Error).stack
  driver = @getDriver()
  driver.getCurrentUrl().then (url) =>
    errMsg = "Element '#{elementDescription}' is still present on page #{url}"
    driver.wait(
      => @isElementPresent(locator).then (value) ->
        not value
      ,
      getConfigValue('stof.elementWait'),
      errMsg
    ).thenCatch (err) ->
      console.error errMsg, stack
      throw err


module.exports = webdriver
