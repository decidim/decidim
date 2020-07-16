# frozen_string_literal: true

module Decidim
  module Comments
    # A command with all the business logic to create a new comment
    class CreateComment < Rectify::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      def initialize(form, author)
        @form = form
        @author = author
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
          commentable: form.commentable,
          root_commentable: root_commentable(form.commentable),
          body: { I18n.locale => parsed.rewrite },
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
        mentioned_groups = parsed.metadata[:user_group].groups
        CommentCreation.publish(@comment, parsed.metadata)
        send_notifications(mentioned_users, mentioned_groups)
      end

      def send_notifications(mentioned_users, mentioned_groups)
        NewCommentNotificationCreator.new(comment, mentioned_users, mentioned_groups).create
      end

      def root_commentable(commentable)
        return commentable.root_commentable if commentable.is_a? Decidim::Comments::Comment

        commentable
      end
    end
  end
end
