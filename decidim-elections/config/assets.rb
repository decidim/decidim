# frozen_string_literal: true

base_path = File.expand_path("..", __dir__)

Decidim::Webpacker.register_path("#{base_path}/app/packs")
Decidim::Webpacker.register_entrypoints(
  decidim_elections: "#{base_path}/app/packs/entrypoints/decidim_elections.js",
  decidim_elections_election_log: "#{base_path}/app/packs/entrypoints/decidim_elections_election_log.js",
  decidim_elections_onboarding: "#{base_path}/app/packs/entrypoints/decidim_elections_onboarding.js",
  decidim_elections_admin_pending_action: "#{base_path}/app/packs/entrypoints/decidim_elections_admin_pending_action.js",
  decidim_elections_admin_trustees_process: "#{base_path}/app/packs/entrypoints/decidim_elections_admin_trustees_process.js",
  decidim_elections_admin_vote_statistics: "#{base_path}/app/packs/entrypoints/decidim_elections_admin_vote_statistics.js",
  decidim_elections_trustee_key_ceremony: "#{base_path}/app/packs/entrypoints/decidim_elections_trustee_key_ceremony.js",
  decidim_elections_trustee_tally_started: "#{base_path}/app/packs/entrypoints/decidim_elections_trustee_tally_started.js",
  decidim_elections_trustee_zone: "#{base_path}/app/packs/entrypoints/decidim_elections_trustee_zone.js",
  decidim_elections_trustee_trustee_zone: "#{base_path}/app/packs/entrypoints/decidim_elections_trustee_trustee_zone.js",
  decidim_elections_voter_casting_vote: "#{base_path}/app/packs/entrypoints/decidim_elections_voter_casting-vote.js",
  decidim_elections_voter_new_vote: "#{base_path}/app/packs/entrypoints/decidim_elections_voter_new-vote.js",
  decidim_elections_voter_setup_preview: "#{base_path}/app/packs/entrypoints/decidim_elections_voter_setup-preview.js",
  decidim_elections_voter_setup_vote: "#{base_path}/app/packs/entrypoints/decidim_elections_voter_setup-vote.js",
  decidim_elections_voter_verify_vote: "#{base_path}/app/packs/entrypoints/decidim_elections_voter_verify-vote.js",
  decidim_votings_admin_monitoring_committee_members_form: "#{base_path}/app/packs/entrypoints/decidim_votings_admin_monitoring_committee_members_form.js",
  decidim_votings_admin_polling_officers_form: "#{base_path}/app/packs/entrypoints/decidim_votings_admin_polling_officers_form.js",
  decidim_votings_admin_polling_officers_picker: "#{base_path}/app/packs/entrypoints/decidim_votings_admin_polling_officers_picker.js",
  decidim_votings_voting_polling_officer_zone_in_person_vote: "#{base_path}/app/packs/entrypoints/decidim_votings_voting_polling_officer_zone-in-person-vote.js",
  decidim_votings_voting_polling_officer_zone_new_closure: "#{base_path}/app/packs/entrypoints/decidim_votings_voting_polling_officer_zone-new-closure.js",
  decidim_votings_voting_polling_officer_zone_edit_closure: "#{base_path}/app/packs/entrypoints/decidim_votings_voting_polling_officer_zone-edit-closure.js",
  decidim_votings_voting_polling_officer_zone_sign_closure: "#{base_path}/app/packs/entrypoints/decidim_votings_voting_polling_officer_zone-sign-closure.js",
  decidim_votings_admin_polling_stations_form: "#{base_path}/app/packs/entrypoints/decidim_votings_admin_polling_stations_form.js",
  decidim_votings_admin_update_census_dataset_status: "#{base_path}/app/packs/entrypoints/decidim_votings_admin_update_census_dataset_status.js",
  decidim_votings_voting_description_cell: "#{base_path}/app/packs/entrypoints/decidim_votings_voting-description-cell.js",
  decidim_votings_in_person_vote: "#{base_path}/app/packs/entrypoints/decidim_votings_in-person-vote.js",
  decidim_votings_admin_votings: "#{base_path}/app/packs/entrypoints/decidim_votings_admin_votings.js"
)
Decidim::Webpacker.register_stylesheet_import("stylesheets/decidim/elections/elections")
Decidim::Webpacker.register_stylesheet_import("stylesheets/decidim/votings/votings")
