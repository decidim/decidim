# frozen_string_literal: true

module Decidim
  module Messaging
    # A form object to be used when users want to message another user.
    class ConversationForm < Decidim::Form
      mimic :conversation

      attribute :body, String
      attribute :recipient_id, Integer

      validates :body, :recipient, presence: true
      validate :check_recipient

      def recipient
        @recipient ||= Decidim::User
                       .includes(:following_follows)
                       .where.not(id: current_user.id)
                       .where(organization: current_user.organization)
                       .where(id: recipient_id)
      end

      def check_recipient
        !@recipient.empty?
      end
    end
  end
end
