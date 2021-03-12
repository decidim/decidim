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
    decidim_admin: './decidim-admin/app/packs/entrypoints/decidim_admin.js',
    decidim_accountability: './decidim-accountability/app/packs/entrypoints/decidim_accountability.js',
    decidim_accountability_admin: './decidim-accountability/app/packs/entrypoints/decidim_accountability_admin.js',
    decidim_assemblies: './decidim-assemblies/app/packs/entrypoints/decidim_assemblies.js',
    decidim_assemblies_admin: './decidim-assemblies/app/packs/entrypoints/decidim_assemblies_admin.js',
    decidim_api_docs: './decidim-api/app/packs/entrypoints/decidim_api_docs.js',
    decidim_budgets: './decidim-budgets/app/packs/entrypoints/decidim_budgets.js',
    decidim_conferences_admin: './decidim-conferences/app/packs/entrypoints/decidim_conferences_admin.js',
    decidim_consultations: './decidim-consultations/app/packs/entrypoints/decidim_consultations.js',
    decidim_core: './decidim-core/app/packs/entrypoints/decidim_core.js',
    decidim_debates_admin: './decidim-debates/app/packs/entrypoints/decidim_debates_admin.js',
    decidim_forms: './decidim-forms/app/packs/entrypoints/decidim_forms.js',
    decidim_forms_admin: './decidim-forms/app/packs/entrypoints/decidim_forms_admin.js',
    decidim_initiatives: './decidim-initiatives/app/packs/entrypoints/decidim_initiatives.js',
    decidim_initiatives_admin: './decidim-initiatives/app/packs/entrypoints/decidim_initiatives_admin.js',
    decidim_meetings: './decidim-meetings/app/packs/entrypoints/decidim_meetings.js',
    decidim_meetings_admin: './decidim-meetings/app/packs/entrypoints/decidim_meetings_admin.js',
    decidim_participatory_processes: './decidim-participatory_processes/app/packs/entrypoints/decidim_participatory_processes.js',
    decidim_participatory_processes_admin: './decidim-participatory_processes/app/packs/entrypoints/decidim_participatory_processes_admin.js',
    decidim_proposals: './decidim-proposals/app/packs/entrypoints/decidim_proposals.js',
    decidim_proposals_admin: './decidim-proposals/app/packs/entrypoints/decidim_proposals_admin.js',
    decidim_system: './decidim-system/app/packs/entrypoints/decidim_system.js',
    decidim_geocoding_provider_photon: './decidim-core/app/packs/entrypoints/decidim_geocoding_provider_photon.js',
    decidim_geocoding_provider_here: './decidim-core/app/packs/entrypoints/decidim_geocoding_provider_here.js',
    decidim_map_provider_default: './decidim-core/app/packs/entrypoints/decidim_map_provider_default.js',
    decidim_map_provider_here: './decidim-core/app/packs/entrypoints/decidim_map_provider_here.js',

  },
}

