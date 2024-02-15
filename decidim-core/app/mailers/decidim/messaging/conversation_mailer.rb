# frozen_string_literal: true

module Decidim
  module Messaging
    # A custom mailer for sending notifications to users when they receive
    # private messages
    class ConversationMailer < Decidim::ApplicationMailer
      include HasConversations

      private

      # rubocop:disable Metrics/ParameterLists
      def send_notification(from:, to:, conversation:, action:, message: nil, third_party: nil)
        with_user(to) do
          @organization = to.organization
          @conversation = conversation
          @sender = from
          @recipient = to
          @third_party = third_party
          @message = message
          @host = @organization.host
          subject = get_subject(action:, sender: @sender, third_party: @third_party)

          mail(to: to.email, subject:)
        end
      end
      # rubocop:enable Metrics/ParameterLists
    end
  end
end
