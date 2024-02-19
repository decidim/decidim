# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # A command with all the business logic when updating an assembly
      # member in the system.
      class UpdateAssemblyMember < Decidim::Commands::UpdateResource
        include ::Decidim::AttachmentAttributesMethods

        fetch_form_attributes :full_name, :gender, :birthday, :birthplace, :ceased_date, :designation_date,
                              :position, :position_other, :weight, :user

        def call
          return broadcast(:invalid) if invalid?

          transaction do
            run_before_hooks
            update_resource
            run_after_hooks
          end

          broadcast(:ok, resource)
        rescue Decidim::Commands::HookError, StandardError
          form.errors.add(:non_user_avatar, resource.errors[:non_user_avatar]) if resource.errors.include? :non_user_avatar
          broadcast(:invalid)
        end

        private

        def attributes
          super.merge(attachment_attributes(:non_user_avatar))
        end

        def extra_params
          {
            resource: {
              title: resource.full_name
            },
            participatory_space: {
              title: resource.assembly.title
            }
          }
        end
      end
    end
  end
end
