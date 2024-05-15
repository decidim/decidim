# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A command with all the business logic when updating a conference
      # partner in the system.
      class UpdatePartner < Decidim::Commands::UpdateResource
        fetch_file_attributes :logo

        fetch_form_attributes :name, :weight, :partner_type, :link

        protected

        def invalid?
          form.invalid? || !resource
        end

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
