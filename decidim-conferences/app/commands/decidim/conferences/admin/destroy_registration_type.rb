# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A command with all the business logic when destroying a conference
      # registration type in the system.
      class DestroyRegistrationType < Decidim::Commands::DestroyResource
        protected

        # The index view only shows the delete action for types without registrations, but the
        # server-side entry point cannot rely on that. The check runs against the actual rows
        # instead of the cached counter, so a direct request cannot delete a type that participants
        # are still registered to.
        def invalid?
          resource.conference_registrations.exists?
        end

        def extra_params
          {
            resource: {
              title: resource.title
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
