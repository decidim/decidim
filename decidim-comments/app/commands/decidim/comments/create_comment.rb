# frozen_string_literal: true

module Decidim
  module Comments
    # A command with all the business logic to create a new comment
    class CreateComment < Rectify::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      def initialize(form, author, commentable)
        @form = form
        @author = author
        @commentable = commentable
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        transaction do
          create_comment
          send_notification_to_moderators
        end

        broadcast(:ok, @comment)
      end

      private

      attr_reader :form

      def create_comment
        @comment = Comment.create!(author: @author,
                                   commentable: @commentable,
                                   root_commentable: root_commentable(@commentable),
                                   body: form.body,
                                   alignment: form.alignment,
                                   decidim_user_group_id: form.user_group_id)
      end

      def send_notification_to_moderators
        Decidim::EventsManager.publish(
          event: "decidim.events.comments.comment_created",
          event_class: Decidim::Comments::CommentCreatedEvent,
          resource: @comment.root_commentable,
          recipient_ids: (@commentable.users_to_notify_on_comment_created - [@author]).pluck(:id),
          extra: {
            comment_id: @comment.id,
            moderation_event: @comment.moderation.upstream_activated? ? true : false,
            new_content: true,
            process_slug: @comment.root_commentable.feature.participatory_space.slug
          }
        )
      end

      def root_commentable(commentable)
        return commentable.root_commentable if commentable.is_a? Decidim::Comments::Comment
        commentable
      end

      def create_moderation
        participatory_space_id = @comment.root_commentable.feature.participatory_space_id
        Decidim::Moderation.create(decidim_participatory_space_id: participatory_space_id, decidim_reportable_type: @comment.class.name, decidim_reportable_id: @comment.id, decidim_participatory_space_type: "Decidim::ParticipatoryProcess")
      end
    end
  end
end
