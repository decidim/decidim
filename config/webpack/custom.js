const path = require('path');

module.exports = {
  module: {
    rules: [
      {
        test: require.resolve("quill"),
        loader: "expose-loader",
        options: {
          exposes: ["Quill"],
        },
      },
      {
        test: require.resolve("jquery"),
        loader: "expose-loader",
        options: {
          exposes: ["$", "jQuery"]
        },
      },
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
      // TODO-blat: modernizr?
      //modernizr$: path.resolve(__dirname, './.modernizrrc')
    }
  }
}

