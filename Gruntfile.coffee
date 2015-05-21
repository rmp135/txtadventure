module.exports = (grunt) ->
    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-contrib-watch'
    grunt.loadNpmTasks 'grunt-contrib-jade'
    grunt.loadNpmTasks 'grunt-contrib-sass'
    grunt.loadNpmTasks 'grunt-contrib-copy'
    grunt.loadNpmTasks 'grunt-contrib-clean'
    grunt.loadNpmTasks 'grunt-contrib-uglify'
    grunt.loadNpmTasks 'grunt-ng-annotate'
    grunt.loadNpmTasks 'grunt-mocha-test'

    grunt.registerTask 'default','watch'
    grunt.registerTask 'test', 'mochaTest'
    grunt.registerTask 'transpile', ['coffee','sass','jade']
    grunt.registerTask 'build', ['clean:build',"copy:devToTest", 'transpile','test']
    grunt.registerTask 'deploy', ['clean:release','copy:testToProd', 'ngAnnotate','uglify']
    
    grunt.initConfig(
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
                    src:'*.scss'
                    dest:'Test/client/css'
                    cwd:'Dev/clientassets/scss',
                    ext:'.css'
                    ]
        coffee: 
            test:
                files:
                    'test.js': 'test.coffee'
            client:
                files: 
                    'Test/client/js/app.js': 'Dev/clientassets/coffee/*.coffee'
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
                    src:'*.jade'
                    dest:'Test/client/views'
                    cwd:'Dev/clientassets/jade'
                    ext:'.html'
                    ]
        copy:
            devToTest:
                files:[ {expand:true, cwd:"Dev/serverassets",src:["views/*"], dest: "Test/server"},
                        {expand:true, cwd:"Dev/clientassets", src:["images/*","js/*"], dest:"Test/client"}]
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
                options:
                    atBegin:true
    )