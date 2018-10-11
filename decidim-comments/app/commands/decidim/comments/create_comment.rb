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

        create_comment

        broadcast(:ok, comment)
      end

      private

      attr_reader :form, :comment

      def create_comment
        parsed = Decidim::ContentProcessor.parse(form.body, current_organization: form.current_organization)

        params = {
          author: @author,
          commentable: @commentable,
          root_commentable: root_commentable(@commentable),
          body: parsed.rewrite,
          alignment: form.alignment,
          decidim_user_group_id: form.user_group_id
        }

        @comment = Decidim.traceability.create!(
          Comment,
          @author,
          params,
          visibility: "public-only"
        )

        mentioned_users = parsed.metadata[:user].users
        CommentCreation.publish(@comment, parsed.metadata)
        send_notifications(mentioned_users)
      end

      def send_notifications(mentioned_users)
        NewCommentNotificationCreator.new(comment, mentioned_users).create
      end

      def root_commentable(commentable)
        return commentable.root_commentable if commentable.is_a? Decidim::Comments::Comment
        commentable
      end
    end
  end
end
