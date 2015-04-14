// Gruntfile for building the cymon globe project

module.exports = function( grunt ) {

  grunt.initConfig({
    pkg: grunt.file.readJSON( 'package.json' ),

    clean: {
      all: [ 'build/tmp/components', 'build/tmp', 'build/*.js', 'public/<%= pkg.name %>.min.js' ]
    },

    browserify: {
      options: {
        debug: true,
        destFile: 'build/bundle.js',
        src: [ 'src/**/*.js', 'src/**/*.jsx' ],
        transform: ['babelify']
      },

      dev: {
        src: '<%= browserify.options.src %>',
        dest: '<%= browserify.options.destFile %>'
      },

      production: {
        options: {
          debug: false
        },
        src: '<%= browserify.options.src %>',
        dest: '<%= browserify.options.destFile %>',
      }
    },

    uglify: {
      options: {
        banner: '/*! <%= pkg.name %> <%= grunt.template.today("dd-mm-yyyy") %> */\n'
      },

      dist: {
        files: {
          'public/<%= pkg.name %>.min.js': [ '<%= browserify.options.destFile %>' ]
        }
      }
    },

    watch: {
      files: [
        'Gruntfile.js',
        'src/**/*.js',
        'src/**/*.jsx'
      ],
      tasks: 'default'
    }
  });

  grunt.loadNpmTasks( 'grunt-browserify' );
  grunt.loadNpmTasks( 'grunt-contrib-uglify' );
  grunt.loadNpmTasks( 'grunt-contrib-watch' );
  grunt.loadNpmTasks( 'grunt-contrib-clean' );

  grunt.registerTask( 'default', [ 'clean:all', 'browserify:production', 'uglify' ]);
};
