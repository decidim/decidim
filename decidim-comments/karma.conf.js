module.exports = function(config) {
  config.set({
    basePath: '',
    frameworks: ['jasmine'],
    files: [
      'app/frontend/entry.test.js'
    ],
    preprocessors: {
      'app/frontend/entry.test.js': ['webpack', 'sourcemap']
    },
    webpack: {
      resolve: {
        extensions: ['', '.js', '.jsx']
      },
      module: {
        noParse: [
          /\/sinon\.js/
        ],
        loaders: [
          { 
              test: /\.jsx?$/,
              exclude: /(node_modules|bower_components)/,
              loaders: ['babel', 'eslint'] 
          },
          { test: require.resolve("react"), loader: "expose?React" },
          { test: require.resolve("react-dom"), loader: "expose?ReactDOM" }
        ]
      },
      externals: {
        'cheerio': 'window',
        'react/lib/ExecutionEnvironment': true,
        'react/lib/ReactContext': true,
        'react/addons': true
      }
    },
    webpackServer: {
      noInfo: true
    },
    plugins: [
      'karma-webpack',
      'karma-jasmine',
      'karma-sourcemap-loader',
      'karma-chrome-launcher',
      'karma-phantomjs-launcher'
    ],
    reporters: ['progress'],
    port: 9876,
    colors: true,
    logLevel: config.LOG_INFO,
    autoWatch: true,
    browsers: ['PhantomJS'],
    singleRun: false
  })
};
