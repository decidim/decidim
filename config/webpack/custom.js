const path = require('path');

module.exports = {
  module: {
    rules: [
      // {
      //   test: /\.modernizrrc$/,
      //   use: ["modernizr-loader"]
      // }
    ]
  },
  resolve: {
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

