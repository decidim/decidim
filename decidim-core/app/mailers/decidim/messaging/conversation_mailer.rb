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
          conversation:,
          message: conversation.messages.first.body,
          action: "new_conversation"
        )
      end

      def new_group_conversation(originator, manager, conversation, group)
        notification_mail(
          from: originator,
          to: manager,
          conversation:,
          message: conversation.messages.first.body,
          action: "new_group_conversation",
          third_party: group
        )
      end

      def comanagers_new_conversation(group, user, conversation, manager)
        notification_mail(
          from: group,
          to: user,
          conversation:,
          message: conversation.messages.first.body,
          action: "comanagers_new_conversation",
          third_party: manager
        )
      end

      def new_message(sender, user, conversation, message)
        notification_mail(
          from: sender,
          to: user,
          conversation:,
          message: message.body,
          action: "new_message"
        )
      end

      def new_group_message(sender, user, conversation, message, group)
        notification_mail(
          from: sender,
          to: user,
          conversation:,
          message: message.body,
          action: "new_group_message",
          third_party: group
        )
      end

      def comanagers_new_message(sender, user, conversation, message, manager)
        notification_mail(
          from: sender,
          to: user,
          conversation:,
          message: message.body,
          action: "comanagers_new_message",
          third_party: manager
        )
      end

      private

      # rubocop:disable Metrics/ParameterLists
      def notification_mail(from:, to:, conversation:, action:, message: nil, third_party: nil)
        with_user(to) do
          @organization = to.organization
          @conversation = conversation
          @sender = from
          @recipient = to
          @third_party = third_party
          @message = message
          @host = @organization.host

          subject = I18n.t(
            "conversation_mailer.#{action}.subject",
            scope: "decidim.messaging",
            sender: @sender.name,
            manager: @third_party&.name,
            group: @third_party&.name
          )

          mail(to: to.email, subject:)
        end
      end
      # rubocop:enable Metrics/ParameterLists
    end
  end
end
