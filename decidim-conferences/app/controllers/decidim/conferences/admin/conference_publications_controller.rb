# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # Controller that allows managing conference publications.
      #
      # i18n-tasks-use t('decidim.admin.conference_publications.create.error')
      # i18n-tasks-use t('decidim.admin.conference_publications.create.success')
      # i18n-tasks-use t('decidim.admin.conference_publications.destroy.error')
      # i18n-tasks-use t('decidim.admin.conference_publications.destroy.success')
      class ConferencePublicationsController < Decidim::Admin::SpacePublicationsController
        include Concerns::ConferenceAdmin

        private

        def enforce_permission_to_publish = enforce_permission_to(:publish, :conference, conference: current_conference)

        def publish_command = PublishConference

        def i18n_scope = "decidim.admin.conference_publications"

        def fallback_location = conferences_path
      end
    end
  end
end
