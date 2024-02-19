# frozen_string_literal: true

module Decidim
  module Initiatives
    class SpawnCommitteeRequestEvent < Decidim::Events::SimpleEvent
      def i18n_scope = "decidim.initiatives.events.spawn_committee_request_event"

      def i18n_options
        {
          applicant_nickname:,
          applicant_profile_url:,
          participatory_space_title:,
          participatory_space_url:,
          resource_path:,
          resource_title:,
          resource_url:,
          scope: i18n_scope
        }
      end

      private

      def applicant_nickname
        applicant.nickname
      end

      def applicant_profile_url
        applicant.profile_url
      end

      def applicant
        @applicant ||= Decidim::UserPresenter.new(
          Decidim::User.find(@extra["applicant"]["id"])
        )
      end
    end
  end
end
