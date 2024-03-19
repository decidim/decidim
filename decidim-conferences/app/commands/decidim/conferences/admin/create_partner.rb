# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A command with all the business logic when creating a new partner
      # in the system.
      class CreatePartner < Decidim::Commands::CreateResource
        fetch_file_attributes :logo

        fetch_form_attributes :name, :weight, :link, :partner_type

        protected

        def resource_class = Decidim::Conferences::Partner

        def extra_params
          {
            resource: {
              title: form.name
            },
            participatory_space: {
              title: form.current_participatory_space.title
            }
          }
        end

        def attributes
          super.merge(conference: form.participatory_space)
        end
      end
    end
  end
end
