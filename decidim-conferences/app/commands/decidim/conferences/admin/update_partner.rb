# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A command with all the business logic when updating a conference
      # partner in the system.
      class UpdatePartner < Decidim::Commands::UpdateResource
        include ::Decidim::AttachmentAttributesMethods

        fetch_form_attributes :name, :weight, :partner_type, :link

        protected

        def invalid? = form.invalid? || !resource

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

        def update_resource
          super
        rescue ActiveRecord::RecordInvalid => e
          form.errors.add(:logo, resource.errors[:logo]) if resource.errors.include? :logo

          raise Decidim::Commands::HookError, e
        end

        def attributes = super.merge(attachment_attributes(:logo))
      end
    end
  end
end
