# frozen_string_literal: true

module Decidim
  module Blogs
    module Admin
      class PublishPost < Decidim::Command
        # Public: Initializes the command.
        #
        # meeting - Decidim::Meetings::Meeting
        # current_user - the user performing the action
        def initialize(post, current_user)
          @post = post
          @current_user = current_user
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form was not valid and we could not proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if post.published?

          transaction do
            publish_post
            send_notification
          end

          broadcast(:ok, post)
        end

        private

        attr_reader :post, :current_user

        def send_notification
          Decidim::EventsManager.publish(
            event: "decidim.events.blogs.post_created",
            event_class: Decidim::Blogs::CreatePostEvent,
            resource: post,
            followers: post.participatory_space.followers
          )
        end

        def publish_post
          @post = Decidim.traceability.perform_action!(
            :publish,
            post,
            current_user,
            visibility: "all"
          ) do
            post.publish!
            post
          end
        end
      end
    end
  end
end
