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
        loader: "babel-loader"
      },
      {
        test: /\.(graphql|gql)$/,
        exclude: /node_modules/,
        loader: "graphql-tag/loader",
      },
      {
        test: /\.json$/,
        loader: "json-loader",
      },
      {
        test: require.resolve("react"),
        loader: "expose-loader",
        options: {
          exposes: ["React"]
        }
      },
      {
        test: require.resolve("@rails/ujs"),
        loader: "expose-loader",
        options: {
          exposes: ["Rails"],
        },
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
    decidim_api_docs: './decidim-api/app/packs/entrypoints/decidim_api_docs.js',
    decidim_budgets: './decidim-budgets/app/packs/entrypoints/decidim_budgets.js',
    decidim_conferences_admin: './decidim-conferences/app/packs/entrypoints/decidim_conferences_admin.js',
    decidim_consultations: './decidim-consultations/app/packs/entrypoints/decidim_consultations.js',
    decidim_forms: './decidim-forms/app/packs/entrypoints/decidim_forms.js',
    decidim_forms_admin: './decidim-forms/app/packs/entrypoints/decidim_forms_admin.js',
  },
}

