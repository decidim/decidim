const path = require('path');

module.exports = {
  module: {
    rules: [
      {
        test: /\.(js|jsx)$/,
        exclude: /node_modules/,
        use: ['babel-loader']
      },
      // {
      //   test: /\.modernizrrc$/,
      //   use: ["modernizr-loader"]
      // }
    ]
  },
  resolve: {
    extensions: ['*', '.js', '.jsx'],
    alias: {
      $: 'jquery/src/jquery',
      // TODO-blat: maybe these aliases are not necessary and can be removed
      // 'window.$': 'jquery',
      // jQuery: 'jquery',
      // 'window.jQuery': 'jquery',
      //modernizr$: path.resolve(__dirname, './.modernizrrc')
    }
  }
}

