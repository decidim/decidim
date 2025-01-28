# frozen_string_literal: true

module Decidim
  module Blogs
    # This command is executed when the user creates a Post from the admin
    # panel.
    class CreatePost < Decidim::Command
      def initialize(form, current_user)
        @form = form
        @current_user = current_user
      end

      # Creates the post if valid.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid) if @form.invalid?

        transaction do
          @post = create_post!
          send_notification
        end

        broadcast(:ok, @post)
        @post
      end

      private

      def create_post!
        attributes = {
          title: { I18n.locale => @form.title },
          body: { I18n.locale => @form.body },
          component: @form.current_component,
          author: @form.author
        }

        Decidim.traceability.create!(
          Post,
          @current_user,
          attributes,
          visibility: "all"
        )
      end

      def send_notification
        Decidim::EventsManager.publish(
          event: "decidim.events.blogs.post_created",
          event_class: Decidim::Blogs::CreatePostEvent,
          resource: @post,
          followers: @post.participatory_space.followers
        )
      end
    end
  end
end
