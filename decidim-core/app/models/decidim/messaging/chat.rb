# frozen_string_literal: true

module Decidim
  module Messaging
    class Chat < ApplicationRecord
      has_many :participations, foreign_key: :decidim_chat_id,
                                class_name: "Decidim::Messaging::Participation",
                                dependent: :destroy,
                                inverse_of: :chat

      has_many :participants, through: :participations

      has_many :messages, foreign_key: :decidim_chat_id,
                          class_name: "Decidim::Messaging::Message",
                          dependent: :destroy,
                          inverse_of: :chat

      def self.start!(originator:, interlocutors:, body:)
        chat = start(
          originator: originator,
          interlocutors: interlocutors,
          body: body
        )

        chat.save!

        chat
      end

      def self.start(originator:, interlocutors:, body:)
        chat = new(participants: [originator] + interlocutors)

        chat.messages.build(sender: originator, body: body)

        chat
      end

      def interlocutors(user)
        participants.where.not(id: user.id)
      end

      def last_message
        messages.last
      end
    end
  end
end
