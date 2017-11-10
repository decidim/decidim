# frozen_string_literal: true

module Decidim
  module Messaging
    # A form object to be used when users want to follow a followable resource.
    class ChatForm < Decidim::Form
      mimic :chat

      attribute :body, String
      attribute :recipient_id, Integer

      validates :body, :recipient, presence: true

      def recipient
        Decidim::User.find_by(id: recipient_id)
      end
    end
  end
end
