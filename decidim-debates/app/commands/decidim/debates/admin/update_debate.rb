# frozen_string_literal: true

module Decidim
  module Debates
    module Admin
      # This command is executed when the user changes a Debate from the admin
      # panel.
      class UpdateDebate < Decidim::Commands::UpdateResource
        include Decidim::MultipleAttachmentsMethods

        fetch_form_attributes :taxonomizations, :information_updates, :instructions, :start_time, :end_time, :comments_enabled

        def call
          return broadcast(:invalid) if invalid?

          if process_attachments?
            build_attachments
            return broadcast(:invalid) if attachments_invalid?
          end

          perform!
          broadcast(:ok, resource)
        rescue ActiveRecord::RecordInvalid
          add_file_attribute_errors!
          broadcast(:invalid)
        rescue Decidim::Commands::HookError
          broadcast(:invalid)
        end

        private

        def attributes
          parsed_title = form.title
          parsed_description = form.description

          attrs = {
            title: parsed_title,
            description: parsed_description
          }

          attrs[:comments_layout] = form.comments_layout if resource.comments_count.zero?

          super.merge(attrs)
        end

        def run_after_hooks
          @attached_to = resource
          document_cleanup!(include_all_attachments: true)
          create_attachments(first_weight: 1) if process_attachments?
        end
      end
    end
  end
end
