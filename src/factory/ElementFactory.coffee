BaseFactory = require './BaseFactory'
WebElement  = require '../WebElement'


class ElementFactory extends BaseFactory
  ###
  Factory for Elements
  ###

  require: (path) ->
    ###
    Always creates WebElement instance

    @return {webdriver.WebElement}
    ###
    WebElement



module.exports = ElementFactory
