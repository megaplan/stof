should = require 'should'
CompileTestSpec = require '../compile/CompileTestSpec'

describe 'Test compiler check', ->
  compileTest = new CompileTestSpec
  defineContextString = 'stof.defineContext(__filename, false)'
  defineContextStringInItBlock = 'stof.defineContext(__filename)'
  doneString = 'stof.done()'

  it 'Checks simple one-line case, which consists of it with describe message without done argument', ->
    coffeeScript = "describe 'One test, one touch', -> it 'should test something', -> nextCall()"
    compileTest.preCompilerCallback(coffeeScript).should.equal """
    #{defineContextString}
    describe 'One test, one touch', -> it 'should test something', -> #{defineContextStringInItBlock}; nextCall(); #{doneString}
"""

  it 'Checks simple case, which consists of it with describe message without done argument', ->
    coffeeScript = """
      describe 'One test, one touch', ->
        it 'should test something', ->
          nextCall()
"""
    compileTest.preCompilerCallback(coffeeScript).should.equal """
      #{defineContextString}
      describe 'One test, one touch', ->
        it 'should test something', ->
          #{defineContextStringInItBlock}; nextCall()
          #{doneString}
"""


  it 'Checks case, which consists of it with describe message with done argument', ->
    coffeeScript = """
      describe 'One test, one touch', ->
        it 'should test something and executes callback', (done) ->
          nextCall()
"""
    compileTest.preCompilerCallback(coffeeScript).should.equal """
      #{defineContextString}
      describe 'One test, one touch', ->
        it 'should test something and executes callback', (done) ->
          #{defineContextStringInItBlock}; nextCall()
          #{doneString}
"""


  it 'Checks test-suite with multiple it-blocks', ->
    coffeeScript = """
      describe 'Two tests, two touches', ->
        it 'should test first case', (done) ->
          firstCall()


        it 'should test second case', ->
          secondCall()
"""
    compileTest.preCompilerCallback(coffeeScript).should.equal """
      #{defineContextString}
      describe 'Two tests, two touches', ->
        it 'should test first case', (done) ->
          #{defineContextStringInItBlock}; firstCall()

          #{doneString}
        it 'should test second case', ->
          #{defineContextStringInItBlock}; secondCall()
          #{doneString}
"""


  it 'should test script with random it-letters in it', ->
    coffeeScript = """
      describe 'It is simple test with it ', ->
        it 'should call it or not call it', ->
          itCallback(' it argument ->')
"""
    compileTest.preCompilerCallback(coffeeScript).should.equal """
      #{defineContextString}
      describe 'It is simple test with it ', ->
        it 'should call it or not call it', ->
          #{defineContextStringInItBlock}; itCallback(' it argument ->')
          #{doneString}
"""

  it 'should compile source with if-block and comment', ->
    coffeeScript = """
      describe 'One test, one touch', ->
        it 'should test something', ->
          # comment
          if something
            nextCall()
"""
    compileTest.preCompilerCallback(coffeeScript).should.equal """
      #{defineContextString}
      describe 'One test, one touch', ->
        it 'should test something', ->
          # comment
          #{defineContextStringInItBlock}; if something
            nextCall()
          #{doneString}
"""

  it 'should compile source with 2 calls', ->
    coffeeScript = """
      describe 'One test, one touch', ->
        it 'should test something', ->
          nextCall().call()
"""
    compileTest.preCompilerCallback(coffeeScript).should.equal """
      #{defineContextString}
      describe 'One test, one touch', ->
        it 'should test something', ->
          #{defineContextStringInItBlock}; nextCall().call()
          #{doneString}
"""

  it 'should compile source with some code after it callback', ->
    coffeeScript = """
      describe 'One test, one touch', ->
        it 'should test something', ->

          if nextCall().call()
            doSomething()

        oneMoreCall()
"""
    compileTest.preCompilerCallback(coffeeScript).should.equal """
      #{defineContextString}
      describe 'One test, one touch', ->
        it 'should test something', ->

          #{defineContextStringInItBlock}; if nextCall().call()
            doSomething()

          #{doneString}
        oneMoreCall()
"""