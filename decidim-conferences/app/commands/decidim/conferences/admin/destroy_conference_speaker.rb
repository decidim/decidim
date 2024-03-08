# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A command with all the business logic when destroying a conference
      # speaker in the system.
      class DestroyConferenceSpeaker < Decidim::Commands::DestroyResource
        protected

        def extra_params
          {
            resource: {
              title: resource.full_name
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
