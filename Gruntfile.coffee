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
  grunt.registerTask 'test', ['mochaTest']
  grunt.registerTask 'transpile', ['coffee','sass','jade']
  grunt.registerTask 'build', ['clean:build',"copy:devToTest", 'transpile','test']
  #grunt.registerTask 'build', ['clean:build',"copy:devToTest", 'transpile']
  grunt.registerTask 'deploy', ['clean:release','copy:testToProd', 'ngAnnotate','uglify']
  
  grunt.initConfig(
    karma: 
      unit:
        options:
          frameworks:['jasmine']
          reporters:['mocha']
          singleRun:true
          
          browsers:["PhantomJS"]
          files:[
            "http://cdnjs.cloudflare.com/ajax/libs/lodash.js/3.8.0/lodash.min.js"
            "https://ajax.googleapis.com/ajax/libs/angularjs/1.4.0-rc.1/angular.js"
            'https://ajax.googleapis.com/ajax/libs/angularjs/1.4.0-rc.1/angular-cookies.js'
            'https://ajax.googleapis.com/ajax/libs/angularjs/1.4.0-rc.1/angular-animate.js'
            'https://ajax.googleapis.com/ajax/libs/angularjs/1.4.0-rc.1/angular-resource.js'
            'https://ajax.googleapis.com/ajax/libs/angularjs/1.4.0-rc.1/angular-touch.js'
            "https://cdnjs.cloudflare.com/ajax/libs/angular-ui-router/0.2.14/angular-ui-router.min.js"
            "https://ajax.googleapis.com/ajax/libs/angularjs/1.4.0-rc.1/angular-mocks.js"
            "./Test/client/js/app.js"
            "./Dev/client/**/*Tests.coffee",
            ]

          preprocessors:
            "./Dev/client/**/*Tests.coffee": ['coffee']

          #logLevel: "DEBUG"

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
        src: ['Dev/server/tests/tests.coffee']
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
        options:
          join:true
        files: 
          'Test/client/js/app.js': ['Dev/client/app/app.coffee', 'Dev/client/app/**/*.coffee','Dev/client/assets/**/*.coffee','!**/*Tests.coffee']
      server:
        files: [
          expand:true
          src:['**/*.coffee','!**/*Tests.coffee',"app.coffee"]
          dest:'Test/server/'
          cwd:'Dev/server/'
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
      client:
        files: ["Dev/client/**/*.coffee"]
        tasks:['coffee:client']
        options:
          atBegin:true
      clientJade:
        files: ["Dev/client/app/**/*.jade"]
        tasks:['jade']
        options:
          atBegin:true
      clientSass:
        files: ["Dev/client/app/**/*.scss"]
        tasks:['sass']
        options:
          sourcemap:"none"
          atBegin:true
      livereload:
        options:
          livereload:true
        files: ["Test/client/**/*", "!Test/client/css/*.map"]
      server:
        files: ["Dev/server/**/*.coffee"]
        tasks:['coffee:server']
        options:
          atBegin:true
      test:
        files: 'test.coffee'
        tasks:['coffee:test']
      clientTests:
        files: ['Dev/client/**/*Tests.coffee']
        tasks:['karma']
      serverTests:
        files: ['Dev/server/**/*Tests.coffee']
        tasks:['mochaTest']
  )