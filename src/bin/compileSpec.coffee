###
  ATTENTION. Compiles only test specs.
  Compiles input stream data into javascript code and forwards it to standard output.
###
CompileTestSpec = require './../compile/CompileTestSpec'
compileTestSpec = new CompileTestSpec

buffer = ''
process.stdin.setEncoding('utf8')

process.stdin.on 'readable', ->
  chunk = process.stdin.read()
  buffer += chunk if chunk != null

process.stdin.on 'end', ->
  process.stdout.write(compileTestSpec.compileString(buffer))

process.stdin.on 'error', (err) ->
  throw err