# frozen_string_literal: true

module Decidim
  module Comments
    # A command with all the business logic to create a new comment
    class CreateComment < Decidim::Command
      delegate :current_user, to: :form
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      def initialize(form)
        @form = form
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

      attr_reader :form, :comment

      def event_arguments
        {
          resource: comment,
          extra: {
            event_author: current_user,
            locale:
          }
        }
      end

      def create_comment
        parsed = Decidim::ContentProcessor.parse(form.body, current_organization: form.current_organization)

        params = {
          author: current_user,
          commentable: form.commentable,
          root_commentable: root_commentable(form.commentable),
          body: { I18n.locale => parsed.rewrite },
          alignment: form.alignment,
          participatory_space: form.current_component.try(:participatory_space)
        }

        @comment = Decidim.traceability.create!(
          Comment,
          current_user,
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
