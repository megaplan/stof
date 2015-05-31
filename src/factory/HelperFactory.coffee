BaseFactory = require './BaseFactory'


class HelperFactory extends BaseFactory
  ###
  Factory for helpers
  ###

  # folder that contains all current type products
  _factoryObjectFolder: 'helpers'
  # helpers cache
  _instances: null


  constructor: ->
    @_instances = {}
    super



  produce: (stof, path, webdriver, args...) ->
    ###
    Reads helper from cache or creates it and stores into cache.

    @param {Stof} stof object @see ../../main.coffee
    @param {String} path to the class in BaseFactory.require() notation
    @param {webdriver.WebDriver} driver instance
    @param {webdriver} webdriver base class
    @param {array} Additional arguments for BaseProduct.init() method

    @return {TestHelper}
    ###
    realPath = stof.resolvePath(path, @_factoryObjectFolder)
    if not @_instances[realPath]?
      @_instances[realPath] = super
    @_instances[realPath]



module.exports = HelperFactory
