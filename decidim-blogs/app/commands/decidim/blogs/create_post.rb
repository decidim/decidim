# frozen_string_literal: true

module Decidim
  module Blogs
    # This command is executed when the user creates a Post from the frontend
    class CreatePost < Decidim::Commands::CreateResource
      include ::Decidim::MultipleAttachmentsMethods

      fetch_form_attributes :author, :taxonomizations

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

      protected

      def run_after_hooks
        @attached_to = resource
        create_attachments(first_weight: 1) if process_attachments?
        send_notification
      end

      def resource_class = Decidim::Blogs::Post

      def extra_params = { visibility: "all" }

      def attributes
        super.merge(
          title: { I18n.locale => form.title },
          body: { I18n.locale => form.body },
          component: form.current_component
        )
      end

      def send_notification
        Decidim::EventsManager.publish(
          event: "decidim.events.blogs.post_created",
          event_class: Decidim::Blogs::CreatePostEvent,
          resource:,
          followers: resource.participatory_space.followers
        )
      end
    end
  end
end
