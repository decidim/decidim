# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A command with all the business logic when destroying a conference
      # registration type in the system.
      class DestroyRegistrationType < Decidim::Commands::DestroyResource
        protected

        def extra_params
          {
            resource: {
              title: registration_type.title
            },
            participatory_space: {
              title: registration_type.conference.title
            }
          }
        end
      end
    end
  end
end
