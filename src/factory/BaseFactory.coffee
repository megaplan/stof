class BaseFactory
  ###
  Base factory
  ###
  # folder that contains all current type products
  _factoryObjectFolder: ''

  # Browser attached to this factory
  browser: null


  constructor: (browser) ->
    ###
    Attach browser to this factory instance

    @param {Browser} — Browser instance, to attach to
    ###
    @browser = browser


  require: (stof, path) ->
    ###
    Requires file by pseudo-path

    @param {Stof} stof object @see ../../main.coffee
    @param {String} pseudo-path. Supported path templates are
      //ClassName - requires ClassName.coffee in current bundle folder
      <bundle>//ClassName - requires ClassName.coffee in the <TestRootDir>/<bundle>/<factoryObjectFolder> folder
      <absolutepath>//ClassName - requires ClassName.coffee in the <absolutepath>/<factoryObjectFolder> folder
    ###
    stof.loadFile(path, @_factoryObjectFolder)


  produce: (stof, path, webdriver, args...) ->
    ###
    Creates a product

    @param {Stof} stof instance
    @param {String} path to the class in BaseFactory.require() notation
    @param {webdriver} webdriver base class
    @param {array} Additional arguments for BaseProduct.init() method

    @return {BaseProduct}
    ###
    new (@require(stof, path))(@browser, webdriver, args)



module.exports = BaseFactory
