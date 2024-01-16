# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A command with all the business logic when creating a new partner
      # in the system.
      class CreatePartner < Decidim::Commands::CreateResource
        fetch_form_attributes :name, :weight, :link, :partner_type, :logo

        protected

        def create_resource(soft: nil)
          super
        rescue ActiveRecord::RecordInvalid => e
          form.errors.add(:logo, resource.errors[:logo]) if resource.errors.include? :logo

          raise Decidim::Commands::HookError, e
        end

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

        def attributes = super.reverse_merge(conference: form.current_participatory_space)
      end
    end
  end
end
