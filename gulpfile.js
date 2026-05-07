'use strict';

const build = require('@microsoft/sp-build-web');
const gulp = require('gulp');
const path = require('path');

build.addSuppression(`Warning - [sass] The local CSS class 'ms-Grid' is not camelCase and will not be type-safe.`);

const copyExtraAssets = build.subTask('copy-extra-assets', function (gulp, buildOptions, done) {
  return gulp.src(path.resolve(__dirname, 'sharepoint/assets/HideMobileUpsellButton.js'))
    .pipe(gulp.dest(path.resolve(__dirname, 'temp/deploy')));
});

build.rig.addPostBuildTask(copyExtraAssets);

build.initialize(gulp);
