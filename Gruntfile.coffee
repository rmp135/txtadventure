module.exports = (grunt) ->
    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-contrib-watch'
    grunt.loadNpmTasks 'grunt-contrib-jade'
    grunt.loadNpmTasks 'grunt-contrib-sass'
    grunt.loadNpmTasks 'grunt-mocha-test'
    grunt.loadNpmTasks 'grunt-named-modules'
    
    grunt.registerTask 'default','watch'
    grunt.registerTask 'test', 'mochaTest'
    grunt.registerTask 'transpile', 'coffee'
    grunt.initConfig(
        mochaTest:
            test:
                options:
                    reporter:'spec'
                    require:'coffee-script/register'
                    bail:true
                src: ['test/*.coffee']
        sass:
            compile:
                files: [
                    expand: true
                    src:'*.scss'
                    dest:'public/css'
                    cwd:'assets/scss',
                    ext:'.css'
                    ]
        coffee: 
            test:
                files:
                    'test.js': 'test.coffee'
            client:
                files: 
                    'public/js/app.js': 'assets/coffee/*.coffee'
            server:
                options:
                    bare:true
                files: [
                    expand:true
                    src:'**/*.coffee'
                    dest:'server'
                    cwd:'serverassets/'
                    ext:'.js'
                    ]
                    
        jade:
            compile:
                files: [
                    expand:true
                    src:'*.jade'
                    dest:'public/views'
                    cwd:'assets/jade'
                    ext:'.html'
                    ]
        watch:
            tests:
                files: ['test/*.coffee']
                tasks: ['test']
            test:
                files: 'test.coffee'
                tasks:['coffee:test']
            coffee:
                files: 'assets/coffee/*.coffee'
                tasks:['coffee:client']
            server:
                files: 'serverassets/**/*.coffee'
                tasks:['coffee:server', 'test']
            jade:
                files:'assets/jade/*.jade'
                tasks:['jade']
            scss:
                files:'assets/scss/*.scss'
                tasks:['sass']
            namedModules:
                files: ['package.json']
                tasks: ['namedModules']
                options:
                    spawned:false
    )
    return