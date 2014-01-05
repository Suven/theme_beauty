module.exports = function(grunt) {

  grunt.initConfig({
    imagemin: {
      dynamic: {
        files: [{
          expand: true,
          cwd: './',
          dest: './',
          src: ['css/**/*.{png,jpg,gif}']
        }]
      }
    },
    coffee: {
      compile: {
        files: {
          'beauty.js': 'beauty.coffee',
        }
      }
    },
    less: {
      compile: {
        options: {
          cleancss: true,
          report: 'min',
        },
        files: {
          "css/style.css": "css/style.less"
        }
      }
    },
    uglify: {
      options: {
        report: 'min',
      },
      dist: {
        files: {
          'beauty.js': ['beauty.js'],
        }
      }
    },
    watch: {
      files: [
        '**/*.coffee',
        '**/*.less',
      ],
      tasks: ['dev']
    }
  });

  grunt.loadNpmTasks('grunt-contrib-imagemin');
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-less');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-watch');

  grunt.registerTask('default', ['coffee', 'less', 'imagemin', 'uglify']);
  grunt.registerTask('dev', ['coffee', 'less']);

};