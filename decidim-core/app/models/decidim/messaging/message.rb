# frozen_string_literal: true

module Decidim
  module Messaging
    class Message < ApplicationRecord
      belongs_to :sender,
                 foreign_key: :decidim_sender_id,
                 class_name: "Decidim::User"

      belongs_to :chat,
                 foreign_key: :decidim_chat_id,
                 class_name: "Decidim::Messaging::Chat"

      validates :sender, :body, presence: true
      validates :body, length: { maximum: 1_000 }
    end
  end
end
