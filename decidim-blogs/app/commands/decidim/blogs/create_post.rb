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
          create_comment_permission_for(@post) if create_comment_permission?
          send_notification
        end

        broadcast(:ok, @post)
        @post
      end

      def create_comment_permission?
        comments_authorization_handler
      end

      def create_comment_permission_for(post)
        form = Decidim::Admin::PermissionsForm.from_params(ah_comment_hash)
                                              .with_context(current_organization: post.organization)

        Decidim::Admin::UpdateResourcePermissions.call(form, post)
      end

      def ah_comment_hash
        { "component_permissions" => { "permissions" => { "comment" => { "authorization_handlers" => [comments_authorization_handler] } } } }
      end

      private

      def comments_authorization_handler
        @comments_authorization_handler ||= Rails.application.secrets.dig(:decidim, :initiatives, :permissions, :comments, :authorization_handler)
      end

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
