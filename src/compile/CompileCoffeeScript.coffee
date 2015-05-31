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

    preCompilerCallback = @preCompilerCallback

    # compile only if destination is outdated or absent
    lstat(src).then (stat) ->
      lstat("#{dstBasename}.js").then (destStat) ->
        destStat.mtime.getTime() < stat.mtime.getTime()
      .catch ->
        true
      .then (doCompile) ->
        if doCompile
          readFile(src, 'utf8').then (coffeeString) ->
            coffeeString = preCompilerCallback(coffeeString, src) if preCompilerCallback

            answer = coffee.compile coffeeString,
              literate: false
              header: true
              compile: true
              bare: true

            mkdirp(dstDir)

            relSrc = src.substr(process.cwd().length + 1)
            console.log ">>> #{relSrc}..."

            writeFile("#{dstBasename}.js", answer)
          .catch (e) ->
            relSrc = src.substr(process.cwd().length + 1)
            console.log "Failed to compile #{relSrc}"
            throw e


module.exports = CompileCoffeeScript