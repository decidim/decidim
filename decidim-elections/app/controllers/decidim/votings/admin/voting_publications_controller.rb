# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # Controller that allows managing voting publications.
      #
      # i18n-tasks-use t('decidim.admin.voting_publications.create.error')
      # i18n-tasks-use t('decidim.admin.voting_publications.create.success')
      # i18n-tasks-use t('decidim.admin.voting_publications.destroy.error')
      # i18n-tasks-use t('decidim.admin.voting_publications.destroy.success')
      class VotingPublicationsController < Decidim::Admin::SpacePublicationsController
        include VotingAdmin

        private

        def enforce_permission_to_publish = enforce_permission_to(:publish, :voting, voting: current_voting)

        def i18n_scope = "decidim.admin.voting_publications"

        def fallback_location = votings_path
      end
    end
  end
end
