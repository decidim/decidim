# frozen_string_literal: true

module Decidim
  module Blogs
    # This command is executed when the user creates a Post from the frontend
    class CreatePost < Decidim::Commands::CreateResource
      fetch_form_attributes :author

      private

      def resource_class = Decidim::Blogs::Post

      def run_after_hooks
        send_notification
      end

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
