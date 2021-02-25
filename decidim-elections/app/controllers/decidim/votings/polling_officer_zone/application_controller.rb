# frozen_string_literal: true

module Decidim
  module Votings
    module PollingOfficerZone
      # This controller is the abstract class from which all polling_officer_zone
      # controllers in their public engines should inherit from.

      class ApplicationController < ::Decidim::ApplicationController
        include Decidim::UserProfile

        helper_method :polling_officers

        private

        def polling_officers
          @polling_officers ||= Decidim::Votings::PollingOfficer.for(current_user)
        end

        def permission_scope
          :polling_officer_zone
        end

        def permission_class_chain
          [
            Decidim::Votings::Permissions,
            Decidim::Permissions
          ]
        end
      end
    end
  end
end
