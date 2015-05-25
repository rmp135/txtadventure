module.exports = (grunt) ->
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-jade'
  grunt.loadNpmTasks 'grunt-contrib-sass'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-karma'
  grunt.loadNpmTasks 'grunt-ng-annotate'
  grunt.loadNpmTasks 'grunt-mocha-test'

  grunt.registerTask 'default','watch'
  grunt.registerTask 'test', ['mochaTest','karma']
  grunt.registerTask 'transpile', ['coffee','sass','jade']
  #grunt.registerTask 'build', ['clean:build',"copy:devToTest", 'transpile','test']
  grunt.registerTask 'build', ['clean:build',"copy:devToTest", 'transpile']
  grunt.registerTask 'deploy', ['clean:release','copy:testToProd', 'ngAnnotate','uglify']
  
  grunt.initConfig(
    karma: 
      unit:
        options:
          frameworks:['jasmine']
          singleRun:true
          
          browsers:["PhantomJS"]
          files:[
            "http://cdnjs.cloudflare.com/ajax/libs/lodash.js/3.8.0/lodash.min.js"
            "https://ajax.googleapis.com/ajax/libs/angularjs/1.4.0-rc.1/angular.js"
            'https://ajax.googleapis.com/ajax/libs/angularjs/1.4.0-rc.1/angular-animate.js'
            'https://ajax.googleapis.com/ajax/libs/angularjs/1.4.0-rc.1/angular-resource.js'
            'https://ajax.googleapis.com/ajax/libs/angularjs/1.4.0-rc.1/angular-touch.js'
            "https://cdnjs.cloudflare.com/ajax/libs/angular-ui-router/0.2.14/angular-ui-router.min.js"
            "./Test/client/js/*.js",
            "https://ajax.googleapis.com/ajax/libs/angularjs/1.4.0-rc.1/angular-mocks.js"
            "./Dev/clientassets/tests/*.coffee"
            ]

          preprocessors:
            "./Dev/clientassets/tests/*.coffee": ['coffee']

          logLevel: "OFF"

          coffeePreprocessor:
            options: 
              bare: true,
              sourceMap: false
            transformPath: (path) -> 
              return path.replace(/\.coffee$/, '.js');
        
    mochaTest:
      test:
        options:
          reporter:'spec'
          require:'coffee-script/register'
          bail:true
        src: ['Dev/tests/tests.coffee']
    sass:
      compile:
        files: [
          expand: true
          src:'**/*.scss'
          dest:'Test/client/css'
          cwd:'Dev/client/app',
          ext:'.css'
          ]
    coffee: 
      test:
        files:
          'test.js': 'test.coffee'
      client:
        files: 
          'Test/client/js/app.js': ['Dev/client/app/app.coffee', 'Dev/client/app/**/*.coffee','Dev/client/assets/**/*.coffee','!**/*Tests.coffee']
      server:
        files: [
          expand:true
          src:['**/*.coffee','!**/*Tests.coffee',"app.coffee"]
          dest:'Test/server/'
          cwd:'Dev/serverassets/'
          ext:'.js'
        ,
          expand:true
          src:['app.coffee']
          dest:'Test/'
          cwd:'Dev/'
          ext:'.js'
          ]
    jade:
      compile:
        files: [
          expand:true
          flatten:true
          src:'**/*.jade'
          dest:'Test/client/partials'
          cwd:'Dev/client/'
          ext:'.html'
          ]
    copy:
      devToTest:
        files:[ {expand:true, cwd:"Dev/server",src:["views/*"], dest: "Test/server"},
                {expand:true, cwd:"Dev/client/assets", src:["images/*","js/*"], dest:"Test/client"}]
      testToProd:
        files: [
          expand:true
          cwd: "./Test"
          src: ["**","!server/*.sqlite3"]
          dest: "./Prod/"
          ]
        
    clean:
      build:["./Test"]
      release:["./Prod"]
        
    uglify:
      client:
        files:
          "Prod/client/js/app.js":["Prod/client/js/app.js"]
    ngAnnotate:
        options:{}
        client:
          files:"Prod/client/js/app.js":["Prod/client/js/app.js"]
    watch:
      build:
        files: ["./Dev/**/*.*"]
        tasks:['build']
        options:
          atBegin:true
      test:
        files: 'test.coffee'
        tasks:['coffee:test']
  )