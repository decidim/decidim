/* eslint-disable */

const path = require("path");

module.exports = {
  module: {
    rules: [
      {
        test: require.resolve("quill"),
        loader: "expose-loader",
        options: {
          exposes: ["Quill"]
        }
      },
      {
        test: require.resolve("jquery"),
        loader: "expose-loader",
        options: {
          exposes: ["$", "jQuery"]
        }
      },
      {
        test: /\.(js|jsx)$/,
        exclude: /node_modules\/(?!tributejs)/,
        loader: "babel-loader"
      },
      {
        test: /\.(graphql|gql)$/,
        loader: "graphql-tag/loader"
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
          exposes: ["Rails"]
        }
      },
      {
        test: [
          /\.md$/,
          /\.odt$/,
        ],
        exclude: [/\.(js|mjs|jsx|ts|tsx)$/],
        type: 'asset/resource',
        generator: {
          filename: 'media/documents/[hash][ext][query]'
        }
      },
      // Overwrite webpacker files rule to amend the filename output
      // and include the name of the file, otherwise some SVGs
      // are not generated because the hash is the same between them
      {
        test: [
          /\.bmp$/,
          /\.gif$/,
          /\.jpe?g$/,
          /\.png$/,
          /\.tiff$/,
          /\.ico$/,
          /\.avif$/,
          /\.webp$/,
          /\.eot$/,
          /\.otf$/,
          /\.ttf$/,
          /\.woff$/,
          /\.woff2$/,
          /\.svg$/
        ],
        exclude: [/\.(js|mjs|jsx|ts|tsx)$/],
        type: 'asset/resource',
        generator: {
          filename: 'media/images/[name]-[hash][ext][query]'
        }
      }
    ]
  },
  resolve: {
    extensions: [".js", ".jsx", ".gql", ".graphql"],
    fallback: {
      crypto: false
    }
  },
  // https://github.com/rails/webpacker/issues/2932
  // As Decidim uses multiple packs, we need to enforce a single runtime, to prevent duplication
  optimization: {
    runtimeChunk: false
  },
  entry: {
    decidim_admin: "../decidim-admin/app/packs/entrypoints/decidim_admin.js",
    decidim_accountability: "../decidim-accountability/app/packs/entrypoints/decidim_accountability.js",
    decidim_accountability_admin: "../decidim-accountability/app/packs/entrypoints/decidim_accountability_admin.js",
    decidim_assemblies: "../decidim-assemblies/app/packs/entrypoints/decidim_assemblies.js",
    decidim_assemblies_admin: "../decidim-assemblies/app/packs/entrypoints/decidim_assemblies_admin.js",
    decidim_api_docs: "../decidim-api/app/packs/entrypoints/decidim_api_docs.js",
    decidim_blogs: "../decidim-blogs/app/packs/entrypoints/decidim_blogs.js",
    decidim_budgets: "../decidim-budgets/app/packs/entrypoints/decidim_budgets.js",
    decidim_conferences_admin: "../decidim-conferences/app/packs/entrypoints/decidim_conferences_admin.js",
    decidim_consultations: "../decidim-consultations/app/packs/entrypoints/decidim_consultations.js",
    decidim_core: "../decidim-core/app/packs/entrypoints/decidim_core.js",
    decidim_conference_diploma: "../decidim-core/app/packs/entrypoints/decidim_conference_diploma.js",
    decidim_debates_admin: "../decidim-debates/app/packs/entrypoints/decidim_debates_admin.js",
    decidim_dev: "../decidim-dev/app/packs/entrypoints/decidim_dev.js",
    decidim_elections: "../decidim-elections/app/packs/entrypoints/decidim_elections.js",
    decidim_elections_election_log: "../decidim-elections/app/packs/entrypoints/decidim_elections_election_log.js",
    decidim_elections_onboarding: "../decidim-elections/app/packs/entrypoints/decidim_elections_onboarding.js",
    decidim_elections_admin_pending_action: "../decidim-elections/app/packs/entrypoints/decidim_elections_admin_pending_action.js",
    decidim_elections_admin_vote_statistics: "../decidim-elections/app/packs/entrypoints/decidim_elections_admin_vote_statistics.js",
    decidim_elections_trustee_key_ceremony: "../decidim-elections/app/packs/entrypoints/decidim_elections_trustee_key_ceremony.js",
    decidim_elections_trustee_tally: "../decidim-elections/app/packs/entrypoints/decidim_elections_trustee_tally.js",
    decidim_elections_trustee_zone: "../decidim-elections/app/packs/entrypoints/decidim_elections_trustee_zone.js",
    decidim_elections_trustee_trustee_zone: "../decidim-elections/app/packs/entrypoints/decidim_elections_trustee_trustee_zone.js",
    decidim_elections_voter_casting_vote: "../decidim-elections/app/packs/entrypoints/decidim_elections_voter_casting-vote.js",
    decidim_elections_voter_new_vote: "../decidim-elections/app/packs/entrypoints/decidim_elections_voter_new-vote.js",
    decidim_elections_voter_setup_preview: "../decidim-elections/app/packs/entrypoints/decidim_elections_voter_setup-preview.js",
    decidim_elections_voter_setup_vote: "../decidim-elections/app/packs/entrypoints/decidim_elections_voter_setup-vote.js",
    decidim_elections_voter_verify_vote: "../decidim-elections/app/packs/entrypoints/decidim_elections_voter_verify-vote.js",
    decidim_email: "../decidim-core/app/packs/entrypoints/decidim_email.js",
    decidim_votings_admin_monitoring_committee_members_form: "../decidim-elections/app/packs/entrypoints/decidim_votings_admin_monitoring_committee_members_form.js",
    decidim_votings_admin_polling_officers_form: "../decidim-elections/app/packs/entrypoints/decidim_votings_admin_polling_officers_form.js",
    decidim_votings_admin_polling_officers_picker: "../decidim-elections/app/packs/entrypoints/decidim_votings_admin_polling_officers_picker.js",
    decidim_votings_admin_polling_stations_form: "../decidim-elections/app/packs/entrypoints/decidim_votings_admin_polling_stations_form.js",
    decidim_votings_admin_update_census_dataset_status: "../decidim-elections/app/packs/entrypoints/decidim_votings_admin_update_census_dataset_status.js",
    decidim_votings_voting_description_cell: "../decidim-elections/app/packs/entrypoints/decidim_votings_voting-description-cell.js",
    decidim_votings_admin_votings: "../decidim-elections/app/packs/entrypoints/decidim_votings_admin_votings.js",
    decidim_forms: "../decidim-forms/app/packs/entrypoints/decidim_forms.js",
    decidim_forms_admin: "../decidim-forms/app/packs/entrypoints/decidim_forms_admin.js",
    decidim_questionnaire_answers_pdf: "../decidim-forms/app/packs/entrypoints/decidim_questionnaire_answers_pdf.js",
    decidim_initiatives: "../decidim-initiatives/app/packs/entrypoints/decidim_initiatives.js",
    decidim_initiatives_admin: "../decidim-initiatives/app/packs/entrypoints/decidim_initiatives_admin.js",
    decidim_initiatives_print: "../decidim-initiatives/app/packs/entrypoints/decidim_initiatives_print.js",
    decidim_initiatives_initiatives_votes: "../decidim-initiatives/app/packs/entrypoints/decidim_initiatives_initiatives_votes.js",
    decidim_map: "../decidim-core/app/packs/entrypoints/decidim_map.js",
    decidim_meetings: "../decidim-meetings/app/packs/entrypoints/decidim_meetings.js",
    decidim_meetings_admin: "../decidim-meetings/app/packs/entrypoints/decidim_meetings_admin.js",
    decidim_pages: "../decidim-pages/app/packs/entrypoints/decidim_pages.js",
    decidim_participatory_processes: "../decidim-participatory_processes/app/packs/entrypoints/decidim_participatory_processes.js",
    decidim_participatory_processes_admin: "../decidim-participatory_processes/app/packs/entrypoints/decidim_participatory_processes_admin.js",
    decidim_proposals: "../decidim-proposals/app/packs/entrypoints/decidim_proposals.js",
    decidim_proposals_admin: "../decidim-proposals/app/packs/entrypoints/decidim_proposals_admin.js",
    decidim_sortitions: "../decidim-sortitions/app/packs/entrypoints/decidim_sortitions.js",
    decidim_system: "../decidim-system/app/packs/entrypoints/decidim_system.js",
    decidim_templates: "../decidim-templates/app/packs/entrypoints/decidim_templates.js",
    decidim_geocoding_provider_photon: "../decidim-core/app/packs/entrypoints/decidim_geocoding_provider_photon.js",
    decidim_geocoding_provider_here: "../decidim-core/app/packs/entrypoints/decidim_geocoding_provider_here.js",
    decidim_map_provider_default: "../decidim-core/app/packs/entrypoints/decidim_map_provider_default.js",
    decidim_map_provider_here: "../decidim-core/app/packs/entrypoints/decidim_map_provider_here.js",
    decidim_widget: "../decidim-core/app/packs/entrypoints/decidim_widget.js",
    decidim_app_design_public: "../decidim_app-design/app/packs/entrypoints/public.js"
  }
}
