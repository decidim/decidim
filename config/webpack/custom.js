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
  },
  // https://github.com/rails/webpacker/issues/2932
  // As Decidim uses multiple packs, we need to enforce a single runtime, to prevent duplication
  optimization: {
    runtimeChunk: false
  },
  entry: {
    decidim_core: './decidim-core/app/packs/entrypoints/decidim_core.js',
    decidim_admin: './decidim-admin/app/packs/entrypoints/decidim_admin.js',
    decidim_accountability: './decidim-accountability/app/packs/entrypoints/decidim_accountability.js',
    decidim_accountability_admin: './decidim-accountability/app/packs/entrypoints/decidim_accountability_admin.js',
    decidim_assemblies: './decidim-assemblies/app/packs/entrypoints/decidim_assemblies.js',
    decidim_assemblies_admin: './decidim-assemblies/app/packs/entrypoints/decidim_assemblies_admin.js',
  },
}

