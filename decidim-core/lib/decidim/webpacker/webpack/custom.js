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
    decidim_admin: "DECIDIM_PATH/decidim-admin/app/packs/entrypoints/decidim_admin.js",
    decidim_accountability: "DECIDIM_PATH/decidim-accountability/app/packs/entrypoints/decidim_accountability.js",
    decidim_accountability_admin: "DECIDIM_PATH/decidim-accountability/app/packs/entrypoints/decidim_accountability_admin.js",
    decidim_assemblies: "DECIDIM_PATH/decidim-assemblies/app/packs/entrypoints/decidim_assemblies.js",
    decidim_assemblies_admin: "DECIDIM_PATH/decidim-assemblies/app/packs/entrypoints/decidim_assemblies_admin.js",
    decidim_api_docs: "DECIDIM_PATH/decidim-api/app/packs/entrypoints/decidim_api_docs.js",
    decidim_blogs: "DECIDIM_PATH/decidim-blogs/app/packs/entrypoints/decidim_blogs.js",
    decidim_budgets: "DECIDIM_PATH/decidim-budgets/app/packs/entrypoints/decidim_budgets.js",
    decidim_conferences_admin: "DECIDIM_PATH/decidim-conferences/app/packs/entrypoints/decidim_conferences_admin.js",
    decidim_consultations: "DECIDIM_PATH/decidim-consultations/app/packs/entrypoints/decidim_consultations.js",
    decidim_core: "DECIDIM_PATH/decidim-core/app/packs/entrypoints/decidim_core.js",
    decidim_conference_diploma: "DECIDIM_PATH/decidim-core/app/packs/entrypoints/decidim_conference_diploma.js",
    decidim_debates_admin: "DECIDIM_PATH/decidim-debates/app/packs/entrypoints/decidim_debates_admin.js",
    decidim_dev: "DECIDIM_PATH/decidim-dev/app/packs/entrypoints/decidim_dev.js",
    decidim_elections: "DECIDIM_PATH/decidim-elections/app/packs/entrypoints/decidim_elections.js",
    decidim_elections_election_log: "DECIDIM_PATH/decidim-elections/app/packs/entrypoints/decidim_elections_election_log.js",
    decidim_elections_onboarding: "DECIDIM_PATH/decidim-elections/app/packs/entrypoints/decidim_elections_onboarding.js",
    decidim_elections_admin_pending_action: "DECIDIM_PATH/decidim-elections/app/packs/entrypoints/decidim_elections_admin_pending_action.js",
    decidim_elections_admin_vote_statistics: "DECIDIM_PATH/decidim-elections/app/packs/entrypoints/decidim_elections_admin_vote_statistics.js",
    decidim_elections_trustee_key_ceremony: "DECIDIM_PATH/decidim-elections/app/packs/entrypoints/decidim_elections_trustee_key_ceremony.js",
    decidim_elections_trustee_tally: "DECIDIM_PATH/decidim-elections/app/packs/entrypoints/decidim_elections_trustee_tally.js",
    decidim_elections_trustee_zone: "DECIDIM_PATH/decidim-elections/app/packs/entrypoints/decidim_elections_trustee_zone.js",
    decidim_elections_trustee_trustee_zone: "DECIDIM_PATH/decidim-elections/app/packs/entrypoints/decidim_elections_trustee_trustee_zone.js",
    decidim_elections_voter_casting_vote: "DECIDIM_PATH/decidim-elections/app/packs/entrypoints/decidim_elections_voter_casting-vote.js",
    decidim_elections_voter_new_vote: "DECIDIM_PATH/decidim-elections/app/packs/entrypoints/decidim_elections_voter_new-vote.js",
    decidim_elections_voter_setup_preview: "DECIDIM_PATH/decidim-elections/app/packs/entrypoints/decidim_elections_voter_setup-preview.js",
    decidim_elections_voter_setup_vote: "DECIDIM_PATH/decidim-elections/app/packs/entrypoints/decidim_elections_voter_setup-vote.js",
    decidim_elections_voter_verify_vote: "DECIDIM_PATH/decidim-elections/app/packs/entrypoints/decidim_elections_voter_verify-vote.js",
    decidim_email: "DECIDIM_PATH/decidim-core/app/packs/entrypoints/decidim_email.js",
    decidim_votings_admin_monitoring_committee_members_form: "DECIDIM_PATH/decidim-elections/app/packs/entrypoints/decidim_votings_admin_monitoring_committee_members_form.js",
    decidim_votings_admin_polling_officers_form: "DECIDIM_PATH/decidim-elections/app/packs/entrypoints/decidim_votings_admin_polling_officers_form.js",
    decidim_votings_admin_polling_officers_picker: "DECIDIM_PATH/decidim-elections/app/packs/entrypoints/decidim_votings_admin_polling_officers_picker.js",
    decidim_votings_voting_polling_officer_zone_new_closure: "DECIDIM_PATH/decidim-elections/app/packs/entrypoints/decidim_votings_voting_polling_officer_zone-new-closure.js",
    decidim_votings_voting_polling_officer_zone_edit_closure: "DECIDIM_PATH/decidim-elections/app/packs/entrypoints/decidim_votings_voting_polling_officer_zone-edit-closure.js",
    decidim_votings_admin_polling_stations_form: "DECIDIM_PATH/decidim-elections/app/packs/entrypoints/decidim_votings_admin_polling_stations_form.js",
    decidim_votings_admin_update_census_dataset_status: "DECIDIM_PATH/decidim-elections/app/packs/entrypoints/decidim_votings_admin_update_census_dataset_status.js",
    decidim_votings_voting_description_cell: "DECIDIM_PATH/decidim-elections/app/packs/entrypoints/decidim_votings_voting-description-cell.js",
    decidim_votings_admin_votings: "DECIDIM_PATH/decidim-elections/app/packs/entrypoints/decidim_votings_admin_votings.js",
    decidim_forms: "DECIDIM_PATH/decidim-forms/app/packs/entrypoints/decidim_forms.js",
    decidim_forms_admin: "DECIDIM_PATH/decidim-forms/app/packs/entrypoints/decidim_forms_admin.js",
    decidim_questionnaire_answers_pdf: "DECIDIM_PATH/decidim-forms/app/packs/entrypoints/decidim_questionnaire_answers_pdf.js",
    decidim_initiatives: "DECIDIM_PATH/decidim-initiatives/app/packs/entrypoints/decidim_initiatives.js",
    decidim_initiatives_admin: "DECIDIM_PATH/decidim-initiatives/app/packs/entrypoints/decidim_initiatives_admin.js",
    decidim_initiatives_print: "DECIDIM_PATH/decidim-initiatives/app/packs/entrypoints/decidim_initiatives_print.js",
    decidim_initiatives_initiatives_votes: "DECIDIM_PATH/decidim-initiatives/app/packs/entrypoints/decidim_initiatives_initiatives_votes.js",
    decidim_map: "DECIDIM_PATH/decidim-core/app/packs/entrypoints/decidim_map.js",
    decidim_meetings: "DECIDIM_PATH/decidim-meetings/app/packs/entrypoints/decidim_meetings.js",
    decidim_meetings_admin: "DECIDIM_PATH/decidim-meetings/app/packs/entrypoints/decidim_meetings_admin.js",
    decidim_pages: "DECIDIM_PATH/decidim-pages/app/packs/entrypoints/decidim_pages.js",
    decidim_participatory_processes: "DECIDIM_PATH/decidim-participatory_processes/app/packs/entrypoints/decidim_participatory_processes.js",
    decidim_participatory_processes_admin: "DECIDIM_PATH/decidim-participatory_processes/app/packs/entrypoints/decidim_participatory_processes_admin.js",
    decidim_proposals: "DECIDIM_PATH/decidim-proposals/app/packs/entrypoints/decidim_proposals.js",
    decidim_proposals_admin: "DECIDIM_PATH/decidim-proposals/app/packs/entrypoints/decidim_proposals_admin.js",
    decidim_sortitions: "DECIDIM_PATH/decidim-sortitions/app/packs/entrypoints/decidim_sortitions.js",
    decidim_system: "DECIDIM_PATH/decidim-system/app/packs/entrypoints/decidim_system.js",
    decidim_templates: "DECIDIM_PATH/decidim-templates/app/packs/entrypoints/decidim_templates.js",
    decidim_geocoding_provider_photon: "DECIDIM_PATH/decidim-core/app/packs/entrypoints/decidim_geocoding_provider_photon.js",
    decidim_geocoding_provider_here: "DECIDIM_PATH/decidim-core/app/packs/entrypoints/decidim_geocoding_provider_here.js",
    decidim_map_provider_default: "DECIDIM_PATH/decidim-core/app/packs/entrypoints/decidim_map_provider_default.js",
    decidim_map_provider_here: "DECIDIM_PATH/decidim-core/app/packs/entrypoints/decidim_map_provider_here.js",
    decidim_widget: "DECIDIM_PATH/decidim-core/app/packs/entrypoints/decidim_widget.js"
  }
}
