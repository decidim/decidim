# frozen_string_literal: true

module Decidim
  module Debates
    # A command with all the business logic when a user updates a debate.
    class UpdateDebate < Decidim::Commands::UpdateResource
      include Decidim::MultipleAttachmentsMethods

      fetch_form_attributes :taxonomizations

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

      def update_resource
        with_events(with_transaction: true) do
          super
        end
      end

      def event_arguments
        {
          resource:,
          extra: {
            event_author: form.current_user,
            locale:
          }
        }
      end

      def extra_params = { visibility: "public-only" }

      def attributes
        parsed_title = form.title
        parsed_description = form.description
        super.merge({
                      title: { I18n.locale => parsed_title },
                      description: { I18n.locale => parsed_description }
                    })
      end

      def run_after_hooks
        @attached_to = resource
        document_cleanup!(include_all_attachments: true)
        create_attachments(first_weight: 1) if process_attachments?
      end
    end
  end
end
