# frozen_string_literal: true

module Decidim
  module Messaging
    class Participation < ApplicationRecord
      belongs_to :chat,
                 foreign_key: :decidim_chat_id,
                 class_name: "Decidim::Messaging::Chat",
                 inverse_of: :participations

      belongs_to :participant,
                 foreign_key: :decidim_participant_id,
                 class_name: "Decidim::User"

      validates :chat, :participant, presence: true

      validates :decidim_chat_id, uniqueness: { scope: :decidim_participant_id }
    end
  end
end
