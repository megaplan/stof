_ = require 'lodash'
webdriver = require 'selenium-webdriver'
BaseProduct = require './factory/BaseProduct'


class WebElement extends BaseProduct
  ###
  Wrapper for webdriver.WebElement
  ###
  _parent: null
  _stringDefinition: null


  init: (locator, @_parent = null, @_elementDescription = null) ->
    ###
    Initializing

    @param {(String|webdriver.By.Hash)} Element locator
    @param {WebElement} Parent element
    ###
    if _.isString(locator)
      @bby = webdriver.By.css(locator)
    else if _.isObject(locator)
      @bby = @_toLocator(locator)
    else
      console.log locator
      throw new Error('Unknown locator type' + typeof locator)


  getElement: ->
    ###
    Finds element by internal stored locator

    @return {webdriver.WebElement}
    ###
    if @_parent
      element = @_parent.getElement().findElement(@bby)
    else
      element = @driver().findElement(@bby)
    element


  ready: (waitForDisplayed = true, timeoutMultiplier = 1) ->
    ###
    Waits until element exists in DOM tree and until it is visible (optional)

    @param {boolean} should it also waits for element visibility
    @param {int} Multiplier for default waiting timeout

    @return {webdriver.promise.Promise}
    ###
    @_getContext().waitForElementPresent(@bby, waitForDisplayed, timeoutMultiplier, @_elementDescription)


  getText: ->
    ###
    Proxy-method for webdriver.WebElement.getText

    @return {webdriver.promise.Promise}
    ###
    @getElement().getText()


  click: ->
    ###
    Proxy-method for webdriver.WebElement.click

    @return {webdriver.promise.Promise}
    ###
    element = @getElement()
    element.click().thenCatch (err) =>
      # Пытаемся корректно обработать протухание элемента, которое приводит к ошибке:
      # stale element reference: element is not attached to the page document
      console.warn "WebElement::click() error in click(): #{err}! Retrying..."
      element = @getElement()
      @ready().then ->
        element.click()


  blur: ->
    ###
    Webdriver does not provide blur method.
    Removes focus from element by calling jQuery.blur()
    ###
    if not @bby.using == 'css selector'
      throw new Error(
        'Blur is not implemented for element, selected with locator, different from css!'
      )
    @driver().executeScript("jQuery('"+@bby.value+"').blur();")


  setValue: (value, clear = true) ->
    ###
    Sets input value
    @param {String} value Value to set
    @param {Boolean} clear Whether need to clear the previous element value
    ###
    element = @getElement()
    if clear
      element.clear().thenCatch (err) =>
        console.warn "WebElement::setValue() error in clear(): #{err}! Retrying..."
        element = @getElement()
        @ready().then ->
          element.clear()
    element.sendKeys(value).then =>
      clear and @checkValue(value)
    .thenCatch (err) =>
      # Пытаемся корректно обработать протухание элемента, которое приводит к ошибке:
      # stale element reference: element is not attached to the page document
      console.warn "WebElement::setValue() error in sendKeys(): #{err}! Retrying..."
      element = @getElement()
      @ready().then =>
        element.sendKeys(value).then =>
          clear and @checkValue(value)


  getValue: ->
    ###
    Returns element value

    @return {webdriver.promise.Promise}
    ###
    @getElement().getAttribute('value')


  checkValue: (value) ->
    ###
    Checks that input value is equal to that
    ###
    @getValue().then (actualValue) ->
      if (value and not actualValue) or (not value and actualValue)
        throw new Error("Element value should be \"#{value}\". Actually \"#{actualValue}\"")


  pressEnter: ->
    ###
    Sends Enter to element
    ###
    @getElement().sendKeys(@webdriver.Key.ENTER)


  hasClass: (className) ->
    ###
    Checks whether element has CSS-class

    @param {String} class name

    @return {webdriver.promise.Promise}
    ###
    @getElement().getAttribute('class').then (value) ->
      value.indexOf(className) != -1


  waitNotPresent: ->
    ###
    Waits until element does not exist in DOM tree

    @return {webdriver.promise.Promise}
    ###
    @_getContext().waitForElementNotPresent(@bby)


  isPresent: (checkIsDisplayed = true) ->
    ###
    Checks whether element is present in DOM tree

    @param {boolean} also check element visibility

    @return {webdriver.promise.Promise}
    ###

    # Если указан родительский элемент, то искать будем в нем, а не во всем DOM дереве
    @_getContext().isElementPresent(@bby)
      .then (isPresent) =>
        if isPresent
          if checkIsDisplayed
            @getElement().isDisplayed()
          else
            true
        else
          false
      .then undefined, (err) =>
        console.warn "Error while checking if WebElement::isPresent()! Going to retry...", err, err.message
        if checkIsDisplayed
          @getElement().isDisplayed()
        else
          true


  _toLocator: (object) ->
    ###
    Converts hash into locator

    @param {webdriver.By.Hash}

    @return {webdriver.Locator}
    ###
    for key of object
      if webdriver.By.hasOwnProperty(key)
        return webdriver.By[key].call(this, object[key])

    throw new Error("Unknown locator")


  setAttribute: (name, value) ->
    ###
    Sets element attribute

    @param {String} Attribute name
    @param {String} Attribute value
    ###
    @driver().executeScript("$('#{@bby.value}').attr('#{name}', '#{value}')")


  _getContext: ->
    ###
    Gets current element context

    If elements has no parent, context will be WebDriver, WebElement otherwise
    Applies only for methods: isElementPresent, findElement, waitForElementPresent, waitForElementNotPresent

    @return {webdriver.WebDriver|webdriver.WebElement}
    ###
    if @_parent
      @_parent.ready()
      @_parent.getElement()
    else
      @driver()


module.exports = WebElement
