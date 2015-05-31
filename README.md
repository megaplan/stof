# Selenium Tests Organization Framework 

## Installation
    npm install stof --save-dev


## Grunt watcher

You can create grunt task to watch the page-objects and specs changes.

First of all 

    npm install grunt-contrib-watch --save-dev

Then add to your Gruntfile

    grunt.initConfig
      test:
        files: [
          'test/**/*.coffee'
        ]
      watch:
        scripts:
          files: [ '<%= test.files %>' ]
          tasks: [ 'compile-tests' ]
          options:
            spawn: false
  
    grunt.event.on 'watch', (action, filepath) ->
      grunt.config('test.files', filepath)
  
    grunt.loadNpmTasks('grunt-contrib-watch')
    grunt.loadTasks('node_modules/stof/src/compile')


## Self testing

To test compile feature run the following command

    mocha lib/test/compile-test.js
