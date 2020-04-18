# frozen_string_literal: true

module Decidim
  module Messaging
    # A custom mailer for sending notifications to users when they receive
    # private messages
    class ConversationMailer < Decidim::ApplicationMailer
      def new_conversation(originator, user, conversation)
        notification_mail(
          from: originator,
          to: user,
          conversation: conversation,
          message: conversation.messages.first.body,
          action: "new_conversation"
        )
      end

      def comanagers_new_conversation(manager, group, user, conversation)
        notification_mail(
          from: group,
          to: user,
          conversation: conversation,
          message: conversation.messages.first.body,
          action: "comanagers_new_conversation",
          manager: manager
        )
      end

      def new_message(sender, user, conversation, message)
        notification_mail(
          from: sender,
          to: user,
          conversation: conversation,
          message: message.body,
          action: "new_message"
        )
      end

      def comanagers_new_message(manager, sender, user, conversation, message)
        notification_mail(
          from: sender,
          to: user,
          conversation: conversation,
          message: message.body,
          action: "comanagers_new_message",
          manager: manager
        )
      end

      private

      # rubocop:disable Metrics/ParameterLists
      def notification_mail(from:, to:, conversation:, action:, message: nil, manager: nil)
        with_user(to) do
          @organization = to.organization
          @conversation = conversation
          @sender = from
          @recipient = to
          @manager = manager
          @message = message
          @host = @organization.host

          subject = I18n.t(
            "conversation_mailer.#{action}.subject",
            scope: "decidim.messaging",
            sender: @sender,
            manager: @manager
          )

          mail(to: to.email, subject: subject)
        end
      end
      # rubocop:enable Metrics/ParameterLists
    end
  end
end
