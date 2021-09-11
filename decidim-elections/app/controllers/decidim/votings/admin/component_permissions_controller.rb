# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # Controller that allows managing the Voting's Component
      # permissions in the admin panel.
      class ComponentPermissionsController < Decidim::Admin::ComponentPermissionsController
        include VotingAdmin

        protected

        def allowed_params
          super.push(:voting_slug)
        end
      end
    end
  end
end
