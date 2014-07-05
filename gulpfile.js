var gulp = require('gulp');
var coffee = require('gulp-coffee');
var mocha = require('gulp-mocha');

require('coffee-script/register');

var paths = {
  lib: ['src/**/*.coffee'],
  spec: ['spec/**/*_spec.coffee']
};

gulp.task('compile', function() {
  return gulp.src(paths.lib)
    .pipe(coffee())
    .pipe(gulp.dest('lib'));
});

gulp.task('watch', function() {
  gulp.watch(paths.lib, ['compile']);
  gulp.watch([paths.lib, paths.spec], ['default']);
});

gulp.task('default', ['compile'], function () {
  return gulp.src(paths.spec, { read: false })
    .pipe(mocha({reporter: 'nyan'}));
});
