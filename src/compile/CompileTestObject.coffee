CompileCoffeeScript = require './CompileCoffeeScript'
path = require 'path'


class CompileTestObject extends CompileCoffeeScript
  ###
  Compiles test page-objects.
  Defines context at the beginning. Appends module.export instruction and restores context in the end of file
  ###

  preCompilerCallback: (coffeeString, src) ->
    """
context = stof.getCurrentContext()
stof.defineContext(__filename, false)

#{coffeeString}

module.exports = #{path.basename(src, '.coffee')}

stof.defineContext(context, false)
"""


module.exports = CompileTestObject