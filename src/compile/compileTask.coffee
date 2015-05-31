fs = require 'fs'
path = require 'path'
Promise = require 'bluebird'

CompileTestObject = require './CompileTestObject'
CompileTestSpec = require './CompileTestSpec'
CompileCoffeeScript = require './CompileCoffeeScript'


module.exports = (grunt) ->

  # promisified functions
  readDir = Promise.promisify(fs.readdir)
  lstat = Promise.promisify(fs.lstat)

  # regexp: !test/.*/specs/.*\.coffee$!
  testSpecPathRegExp = new RegExp('/specs/.*\\.coffee$')
  testObjectPathRegExp = new RegExp('/(page-objects|helpers)/.*\\.coffee$')

  compileTestObject = new CompileTestObject
  compileTestSpec = new CompileTestSpec
  compileCoffeeScript = new CompileCoffeeScript

  ###
  Recursive walks throw target path and runs callback on each file and dir

  @param String target path
  @param Function[Promise] callbackFile calls on each file
  @param Function[Promise] callbackDir calls on each directory
  ###
  walk = (target, callbackFile, callbackDir = null) ->
    lstat(target).then (stat) ->
      if stat.isDirectory()
        readDir(target).then (list) ->
          promises = (walk(path.resolve(target, file), callbackFile, callbackDir) for file in list)
          Promise.all(promises)
        .then ->
          callbackDir(target) if callbackDir
      else if stat.isFile()
        callbackFile(target)
      else
    .catch (err) ->
      throw err unless err.code == 'ENOENT'


  resolvePath = (path) ->
    if path.charAt(0) != '/'
      "#{process.cwd()}/#{path}"
    else
      path


  ###
  Compiles all page-objects and specs from specified location into specified target.

  @option tests-dir, default - test
  @option target-dir, default - target
  ###
  grunt.registerTask 'compile-tests', 'Compile STOF page objects and specs',
    ->
      done = @async()

      # grunt options
      testsDir = grunt.option('tests-dir') or 'test'
      targetDir = grunt.option('target-dir') or 'target'

      testsDir = resolvePath(testsDir)
      targetDir = resolvePath(targetDir)

      configTestFiles = grunt.config('testCompile.files')
      changedFile = if configTestFiles and not Array.isArray(configTestFiles) then path.resolve(configTestFiles) else null
      filterChangedFile = (file) -> null == changedFile or changedFile == file

      walk testsDir, (target) ->
        if filterChangedFile(target)
          return compileTestSpec.compile(target, targetDir) if target.match(testSpecPathRegExp)
          return compileTestObject.compile(target, targetDir) if target.match(testObjectPathRegExp)
          return compileCoffeeScript.compile(target, targetDir) if target.substring(target.length - 7) == '.coffee'
      .then ->
        console.log 'Done'
        done()
      .done()


  ###
  Cleans target test directory
  ###
  grunt.registerTask 'clean-tests', 'Clean STOF target directory', ->
    done = @async()

    targetDir = grunt.option('target-dir') or 'target/test'
    targetDir = resolvePath(targetDir)

    # promisified functions
    unlink = Promise.promisify(fs.unlink)
    rmdir = Promise.promisify(fs.rmdir)

    walk targetDir,
      (file) -> unlink(file),
      (dir) -> rmdir(dir)
    .then ->
      console.log 'Done'
      done()

