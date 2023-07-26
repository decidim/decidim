# frozen_string_literal: true

module Decidim
  module Comments
    # A command with all the business logic to create a new comment
    class CreateComment < Decidim::Command
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
      # - :invalid if the form was not valid and we could not proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        with_events do
          create_comment
        end

        broadcast(:ok, comment)
      end

      private

      attr_reader :form, :comment, :author

      def event_arguments
        {
          resource: comment,
          extra: {
            event_author: form.current_user,
            locale:
          }
        }
      end

      def create_comment
        parsed = Decidim::ContentProcessor.parse(form.body, current_organization: form.current_organization)

        params = {
          author:,
          commentable: form.commentable,
          root_commentable: root_commentable(form.commentable),
          body: { I18n.locale => parsed.rewrite },
          alignment: form.alignment,
          decidim_user_group_id: form.user_group_id,
          participatory_space: form.current_component.try(:participatory_space)
        }

        @comment = Decidim.traceability.create!(
          Comment,
          author,
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
