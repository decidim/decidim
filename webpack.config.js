const webpack                     = require('webpack');
const webpackValidator            = require('webpack-validator');
const { getIfUtils, removeEmpty } = require('webpack-config-utils');
const ProgressBarPlugin           = require('progress-bar-webpack-plugin');

module.exports = env => {
  const { ifProd } = getIfUtils(env);

  const config = webpackValidator({
    entry: {
      comments: './decidim-comments/app/frontend/entry.js'
    },
    output: {
      path: __dirname,
      filename: 'decidim-[name]/app/assets/javascripts/decidim/[name]/bundle.js'
    },
    resolve: {
      extensions: ['.js', '.jsx', '.graphql', '.yml']
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
          test: /\.(yml|yaml)$/,
          loaders: ['json-loader', 'yaml-loader']
        },
        {
          test: /\.(graphql|gql)$/,
          loaders: ['raw-loader']
        },
        { 
          test: require.resolve("react"),
          loader: "expose-loader?React"
        },
        { 
          test: require.resolve("react-dom"),
          loader: "expose-loader?ReactDOM"
        }
      ]
    },
    plugins: [
      new ProgressBarPlugin(),
      new webpack.DefinePlugin({
        'process.env': {
          NODE_ENV: ifProd('"production"', '"development"')
        }
      })
    ]
  });
  return config;
};
