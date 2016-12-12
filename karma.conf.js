process.env.BABEL_ENV = 'test';
const webpackEnv = { test: true };
const webpackConfig = require('./webpack.config.babel')(webpackEnv);

const testGlob = 'decidim-*/app/frontend/entry.test.js';
const srcGlob = 'decidim-*/app/frontend/**/!(*.test.*)';

module.exports = function(config) {
  config.set({
    basePath: '',
    frameworks: ['jasmine'],
    files: [testGlob, srcGlob],
    exclude: ['decidim-*/app/frontend/entry.js'],
    preprocessors: {
      [testGlob]: ['webpack'],
      [srcGlob]: ['webpack']
    },
    webpack: webpackConfig,
    webpackMiddleware: { noInfo: true },
    reporters: ['progress', 'coverage'],
    coverageReporter: {
      reporters: [
        {type: 'lcov', dir: 'coverage/', subdir: '.'},
        {type: 'json', dir: 'coverage/', subdir: '.'},
        {type: 'text-summary'},
      ],
    },
    port: 9876,
    colors: true,
    logLevel: config.LOG_INFO,
    autoWatch: false,
    browsers: ['PhantomJS'],
    singleRun: true,
    concurrency: Infinity
  })
};
