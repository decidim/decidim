# frozen_string_literal: true

module Decidim
  module Blogs
    module Admin
      # This command is executed when the user creates a Post from the admin
      # panel.
      class CreatePost < Rectify::Command
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
            create_post!
            send_notification
          end

          broadcast(:ok, @post)
        end

        private

        def create_post!
          attributes = {
            title: @form.title,
            body: @form.body,
            component: @form.current_component,
            author: @current_user
          }

          @post = Decidim.traceability.create!(
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
end
