# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A command with all the business logic when updating a conference
      # speaker in the system.
      class UpdateMediaLink < Decidim::Commands::UpdateResource
        fetch_form_attributes :title, :link, :weight, :date

        protected

        def invalid? = form.invalid? || !resource

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
