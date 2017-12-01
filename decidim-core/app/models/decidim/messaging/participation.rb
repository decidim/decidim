# frozen_string_literal: true

module Decidim
  module Messaging
    #
    # Holds a many-to-many relationship between conversations and their participants
    #
    class Participation < ApplicationRecord
      belongs_to :conversation,
                 foreign_key: :decidim_conversation_id,
                 class_name: "Decidim::Messaging::Conversation",
                 inverse_of: :participations

      belongs_to :participant,
                 foreign_key: :decidim_participant_id,
                 class_name: "Decidim::User"

      validates :conversation, :participant, presence: true

      validates :decidim_conversation_id, uniqueness: { scope: :decidim_participant_id }
    end
  end
end
