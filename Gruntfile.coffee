module.exports = (grunt) ->
    grunt.loadNpmTasks('grunt-contrib-coffee')
    grunt.loadNpmTasks('grunt-contrib-watch')
    grunt.loadNpmTasks('grunt-contrib-jade')
    grunt.loadNpmTasks('grunt-contrib-sass')
    
    grunt.registerTask('default','watch')
    grunt.initConfig(
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
            compile:
                files: 
                    'public/js/app.js': 'assets/coffee/*.coffee'
            server:
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
            coffee:
                files: 'assets/coffee/*.coffee'
                tasks:['coffee']
            server:
                files: 'serverassets/**/*.coffee'
                tasks:['coffee:server']
            jade:
                files:'assets/jade/*.jade'
                tasks:['jade']
            scss:
                files:'assets/scss/*.scss'
                tasks:['sass']
    )
    return