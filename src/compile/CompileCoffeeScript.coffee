fs = require 'fs'
path = require 'path'
mkdirp = require('mkdirp').sync

coffee = require 'coffee-script'

Promise = require 'bluebird'
# promisified functions
readFile = Promise.promisify(fs.readFile)
writeFile = Promise.promisify(fs.writeFile)
lstat = Promise.promisify(fs.lstat)


class CompileCoffeeScript

  # callback which runs before coffee-script file compilation
  preCompilerCallback: null

  compile: (src, targetDir) ->
    dirname = path.dirname(src)
    basename = path.basename(src, '.coffee')

    dirname = dirname.substr(process.cwd().length + 1)
    dstDir = "#{ targetDir }/#{ dirname }"

    dstBasename = "#{ dstDir }/#{ basename }"
    compileString = @compileString

    # compile only if destination is outdated or absent
    lstat(src).then (stat) ->
      lstat("#{dstBasename}.js").then (destStat) ->
        destStat.mtime.getTime() < stat.mtime.getTime()
      .catch ->
        true
      .then (doCompile) ->
        if doCompile
          readFile(src, 'utf8').then (coffeeString) =>
            answer = compileString(coffeeString, src)

            mkdirp(dstDir)

            relSrc = src.substr(process.cwd().length + 1)
            console.log ">>> #{relSrc}..."

            writeFile("#{dstBasename}.js", answer)
          .catch (e) ->
            relSrc = src.substr(process.cwd().length + 1)
            console.log "Failed to compile #{relSrc}"
            throw e


  compileString: (coffeeString, filename = '') ->
    ###
    Compiles CoffeeScript source code of spec, pageObject or helper.

    @param {String} coffeeString
    @param {String} filename Current compiling file name

    @return {String} compiled JavaScript
    ###
    coffeeString = @preCompilerCallback(coffeeString, filename) if @preCompilerCallback

    coffee.compile coffeeString,
      literate: false
      header: true
      compile: true
      bare: true


module.exports = CompileCoffeeScript