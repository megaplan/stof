###
Registers compiler for require. Useful for mocha test runner (see usage section below).
Compiles coffee script source according to stof spec rules.

Usage:
  mocha --compilers coffee:stof/register myTestSpec.coffee
###
fs = require('fs')
path = require('path')

CompileTestSpec = require './compile/CompileTestSpec'
compileTestSpec = new CompileTestSpec

require.extensions['.coffee'] = (module, filename) ->
  process.chdir(path.dirname(filename))
  content = fs.readFileSync(filename, 'utf8')
  compiled = compileTestSpec.compileString(content)
  module._compile(compiled, filename)