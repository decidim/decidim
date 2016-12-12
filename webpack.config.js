const webpackValidator = require('webpack-validator')

module.exports = env => {
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
    }
  });
  return config;
};

// const path = require('path');
// const webpack = require('webpack');

// module.exports = {
//     entry: {
//         comments: './decidim-comments/app/frontend/entry.js'
//     },
//     output: {
//         path: __dirname,
//         filename: 'decidim-[name]/app/assets/javascripts/decidim/[name]/bundle.js'
//     },
//     resolve: {
//         extensions: ['', '.js', '.jsx', '.graphql', '.yml']
//     },
//     plugins: [
//         new webpack.DefinePlugin({
//             'process.env.NODE_ENV': JSON.stringify(process.env.NODE_ENV || 'development')
//         }),
//     ],
//     module: {
//         noParse: [
//           /\/sinon\.js/
//         ],
//         loaders: [
//             { 
//                 test: /\.jsx?$/,
//                 exclude: /node_modules/,
//                 loaders: ['babel', 'eslint'] 
//             },
//             {
//                 test: /\.(graphql|gql)$/,
//                 exclude: /node_modules/,
//                 loaders: ['raw']
//             },
//             {
//                 test: /\.(jpg|png)$/,
//                 loader: 'url'
//             },
//             {
//                 test: /\.(yml|yaml)$/,
//                 loaders: ['json', 'yaml']
//             },
//             { 
//                 test: require.resolve("react"),
//                 loader: "expose?React"
//             },
//             { 
//                 test: require.resolve("react-dom"),
//                 loader: "expose?ReactDOM"
//             }
//         ]
//     },
//     externals: {
//         'cheerio': 'window',
//         'react/lib/ExecutionEnvironment': true,
//         'react/lib/ReactContext': true,
//         'react/addons': true
//     },
//     eslint: {
//         configFile: '.eslintrc.json'
//     }
// };

      