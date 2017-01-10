process.env.BABEL_ENV = 'test';
const webpackEnv = { test: true };
const webpackConfig = require('./webpack.config')(webpackEnv);

const testGlob = 'decidim-*/app/frontend/entry.test.js';
const srcGlob = 'decidim-*/app/frontend/**/!(*.test.*)';

module.exports = function(config) {
  config.set({
    basePath: '',
    frameworks: ['jasmine'],
    files: [testGlob, srcGlob, 'decidim-meetings/**/*.component.js.es6', 'decidim-meetings/**/*.test.js'],
    exclude: ['decidim-*/app/frontend/entry.js'],
    preprocessors: {
      [testGlob]: ['webpack', 'sourcemap'],
      [srcGlob]: ['webpack'],
      'decidim-meetings/**/*.test.js': ['webpack', 'sourcemap'],
      'decidim-meetings/**/*.component.js.es6': ['webpack']
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
    plugins: [
      'karma-webpack',
      'karma-jasmine',
      'karma-sourcemap-loader',
      'karma-phantomjs-launcher',
      'karma-coverage'
    ],
    port: 9876,
    colors: true,
    logLevel: config.LOG_INFO,
    autoWatch: false,
    browsers: ['PhantomJS'],
    singleRun: true,
    concurrency: Infinity
  })
};
