# frozen_string_literal: true

module Decidim
  module Blogs
    # This command is executed when the user updates a Post from the frontend
    class UpdatePost < Decidim::Commands::UpdateResource
      include ::Decidim::MultipleAttachmentsMethods

      fetch_form_attributes :title, :body, :taxonomizations

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

      def resource_class = Decidim::Blogs::Post

      def attributes
        super.merge(
          title: { I18n.locale => form.title },
          body: { I18n.locale => form.body }
        )
      end

      def run_after_hooks
        @attached_to = resource
        document_cleanup!(include_all_attachments: true)
        create_attachments(first_weight: 1) if process_attachments?
      end
    end
  end
end
