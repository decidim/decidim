# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A command with all the business logic when destroying a conference
      # Partner in the system.
      class DestroyPartner < Decidim::Commands::DestroyResource
        protected

        def extra_params
          {
            resource: {
              title: resource.name
            },
            participatory_space: {
              title: resource.conference.title
            }
          }
        end
      end
    end
  end
end
