const webpack              = require('webpack');
const webpackConfigUtils   = require('webpack-config-utils');
const getIfUtils           = webpackConfigUtils.getIfUtils;
const ProgressBarPlugin    = require('progress-bar-webpack-plugin');
const BundleAnalyzerPlugin = require('webpack-bundle-analyzer').BundleAnalyzerPlugin;

module.exports = env => {
  const envUtils = getIfUtils(env);
  const ifProd = envUtils.ifProd;
  const ifTest = envUtils.ifTest;

  const config = {
    entry: {
      comments: './decidim-comments/app/frontend/entry.ts'
    },
    output: {
      path: __dirname,
      filename: 'decidim-[name]/app/assets/javascripts/decidim/[name]/bundle.js'
    },
    resolve: {
      extensions: ['.js', '.jsx', '.ts', '.tsx', '.yml']
    },
    devtool: ifProd('source-map', 'eval'),
    module: {
      loaders: [
        {
          test: /\.jsx?$/,
          exclude: /node_modules/,
          loaders: ['babel-loader', 'eslint-loader']
        },
        {
          test: /\.tsx?$/,
          loaders: ['babel-loader', 'awesome-typescript-loader']
        },
        {
          test: /\.js.es6$/,
          loaders: ['babel-loader', 'eslint-loader']
        },
        {
          test: /\.(yml|yaml)$/,
          loaders: ['json-loader', 'yaml-loader']
        },
        {
          test: /\.(graphql|gql)$/,
          exclude: /node_modules/,
          loader: 'graphql-tag/loader'
        },
        {
          test: /\.json$/,
          loaders: ['json-loader']
        },
        {
          test: require.resolve("react"),
          loader: "expose-loader?React"
        },
        {
          test: require.resolve("jquery"),
          loader: "expose-loader?$"
        }
      ]
    },
    plugins: [
      new ProgressBarPlugin(),
      new webpack.DefinePlugin({
        'process.env': {
          NODE_ENV: ifProd('"production"', '"development"')
        }
      }),
      new BundleAnalyzerPlugin({
        analyzerMode: ifTest('disabled', 'static'),
        reportFilename: 'webpack.report.html',
        openAnalyzer: false
      })
    ]
  };
  return config;
};
