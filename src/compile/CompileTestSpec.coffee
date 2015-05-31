CompileCoffeeScript = require './CompileCoffeeScript'
coffee = require 'coffee-script'

defineContextString = 'stof.defineContext(__filename, false)'
defineContextStringInItBlock = 'stof.defineContext(__filename); '
doneString = 'stof.done()'


# private functions
repeat = (count, str = ' ') ->
  ###
  Repeat `str` string `count` times

  @param {int} count
  @param {String} string to repeat

  @return {int} string
  ###
  Array(count + 1).join(' ')


linesToPasteSorter = (a, b) ->
  ###
  Sorter for list of elements. Elements with greater position go first
  ###
  a.position < b.position


trimRegexp = new RegExp('\\n+\\s*$')
blankLinesRegexp = new RegExp('\\n\\s+\\n')

class CompileTestSpec extends CompileCoffeeScript
  ###
  Compiles test specs.
  Defines context at the beginning of file and in each `it` callback.
  Adds done call into each `it`
  ###

  preCompilerCallback: (coffeeString) ->
    # Parse source coffee script string
    tokens = coffee.tokens(coffeeString)

    # some flags
    inIt = false
    inItCallback = false
    firstItToken = false

    # object where key is line number and value is array of data to add
    linesToPaste = {}

    # call start/end counter. When call starts it increments, when call ends it decrements
    callLevel = 0

    itIndent = 0
    itLine = 0

    # walk through the tokens and gather lines to paste object
    for key, token of tokens
      if not inIt and token[0] == 'IDENTIFIER' and token[1] == 'it'
        inIt = true
        itIndent = token[2].first_column
        itLine = token[2].first_line
        callLevel = 0
      else if inIt
        if token[0] == '->' and not inItCallback
          inItCallback = true
          firstItToken = true
        else if token[0] == 'CALL_START'
          callLevel++
        else if token[0] == 'CALL_END'
          callLevel--
          unless callLevel
            # add done() call at position of last call in `it` callback
            inIt = false
            inItCallback = false

            if token[2].first_line == itLine # one-line callback
              content = "; #{doneString}"
            else
              content = "\n#{repeat(itIndent + 2)}#{doneString}\n#{repeat(itIndent)}"

            linesToPaste[token[2].first_line] or= []
            linesToPaste[token[2].first_line].push
              position: token[2].first_column + 1
              content: content
        else if inItCallback and firstItToken and token.variable
          # define context just before first identifier in `it` callback
          firstItToken = false
          linesToPaste[token[2].first_line] = [
            position: token[2].first_column
            content: defineContextStringInItBlock
          ]

    # now let's paste all needed data
    sourceLines = coffeeString.split("\n")

    for num, lines of linesToPaste
      line = sourceLines[num]
      # paste from the end of the line
      for data in lines.sort(linesToPasteSorter)
        line = line.substr(0, data.position) + data.content + line.substr(data.position)
      sourceLines[num] = line

    coffeeString = sourceLines.join("\n")

    coffeeString = defineContextString + "\n" + coffeeString
    # trim trailing new line(s) and clean lines that contains only spaces
    coffeeString.replace(trimRegexp, '')
      .replace(blankLinesRegexp, "\n\n")


module.exports = CompileTestSpec
