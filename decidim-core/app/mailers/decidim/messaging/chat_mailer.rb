# frozen_string_literal: true

module Decidim
  module Messaging
    # A custom mailer for sending notifications to users when they receive
    # private messages
    class ChatMailer < Decidim::ApplicationMailer
      def new_chat(originator, user, chat)
        notification_mail(
          from: originator,
          to: user,
          chat: chat,
          action: "new_chat"
        )
      end

      def new_message(sender, user, chat)
        notification_mail(
          from: sender,
          to: user,
          chat: chat,
          action: "new_chat"
        )
      end

      private

      def notification_mail(from:, to:, chat:, action:)
        with_user(to) do
          @organization = to.organization
          @chat = chat
          @sender = from.name
          @recipient = to.name
          @host = @organization.host

          subject = I18n.t(
            "chat_mailer.#{action}.subject",
            scope: "decidim.messaging",
            sender: @sender
          )

          mail(to: to.email, subject: subject)
        end
      end
    end
  end
end
