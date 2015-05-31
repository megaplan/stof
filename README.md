# Selenium Tests Organization Framework 

## Installation
    npm install stof --save-dev


## Grunt watcher

You can create grunt task to watch the page-objects and specs changes.

First of all 

    npm install grunt-contrib-watch --save-dev

Then add to your Gruntfile

    grunt.config.merge
      testCompile:
        files: [
          'test/**/*.coffee'
        ]
      watch:
        scripts:
          files: [ '<%= testCompile.files %>' ]
          tasks: [ 'compile-tests' ]
          options:
            spawn: false
  
    grunt.event.on 'watch', (action, filepath) ->
      grunt.config('testCompile.files', filepath)
  
    grunt.loadNpmTasks('grunt-contrib-watch')
    grunt.loadTasks('node_modules/stof/lib/compile')
  
    grunt.registerTask 'watch-tests', 'Compiles all changed tests at start and watch for new changes continuously', ->
      grunt.task.run 'compile-tests'
      grunt.task.run 'watch'


## Compiler testing

To test compile feature run the following command

    mocha lib/test/compile-test.js
