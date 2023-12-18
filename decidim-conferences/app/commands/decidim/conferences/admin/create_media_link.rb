# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A command with all the business logic when creating a new
      # media link for conference in the system.
      class CreateMediaLink < Decidim::Commands::CreateResource
        fetch_form_attributes :title, :link, :weight, :date

        protected

        def resource_class = Decidim::Conferences::MediaLink

        def extra_params
          {
            resource: {
              title: form.title
            },
            participatory_space: {
              title: form.current_participatory_space.title
            }
          }
        end

        def attributes
          super.merge(conference: form.current_participatory_space)
        end
      end
    end
  end
end
