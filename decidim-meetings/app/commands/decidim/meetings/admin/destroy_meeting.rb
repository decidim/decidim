# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This command is executed when the user destroys a Meeting from the admin
      # panel.
      class DestroyMeeting < Decidim::Commands::DestroyResource
        protected

        def invalid? = proposals.any?

        def proposals
          return [] unless Decidim::Meetings.enable_proposal_linking

          @proposals ||= resource.authored_proposals.load
        end
      end
    end
  end
end
