BaseProduct = require './../factory/BaseProduct'


class PageObject extends BaseProduct
  ###
  Base class for page-object
  ###

  # Parent of all PageObject selectors
  parentElement: null

  # PageObject should wait for readyElement. It is equal to context by default
  readyElement: null

  init: (parentSelector) ->
    ###
    Initializing

    It does some magic: translates selectors from property elements into object properties.
    You can specify css selectors or anything from {webdriver.By.Hash}
    For example,
      elements:
        email: '.email'             # css selector
        password: '.password'       # css selector
        coordinators:
          xpath: "//div[@class='b-first-content']//div[@class='b-first-content-wrapper']/div[@class='title']"
        body:
          tagName: 'body'

    will be converted into PageObject.email, PageObject.password etc. properties, where type of these properties is WebElement

    Also you can specify readyElement property which will be used in ready-method for waiting page-object is ready
    ###
    super
    if @parentElement
      parentSelector = if parentSelector then parentSelector + ' ' + @parentElement else @parentElement

    parentElement = @browser.element(parentSelector) if parentSelector
    for element, cssSelector of @elements
      @[element] = @browser.element(cssSelector, parentElement, "#{@constructor.name}.#{element}")

    if @readyElement
      @readyElement = @browser.element(@readyElement, parentElement)
    else if parentSelector
      @readyElement = @browser.element(parentSelector)


  ready: ->
    ###
    Waits until readyElement is ready if readyElement is specified. Otherwise returns resolved promise

    @return {webdriver.promise.Promise}
    ###
    if @readyElement
      promise = @readyElement.ready()
      if @onReadyWait then @onReadyWait() else promise
    else
      @driver().controlFlow().execute( -> )



module.exports = PageObject
