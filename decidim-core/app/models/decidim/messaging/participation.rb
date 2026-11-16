# frozen_string_literal: true

module Decidim
  module Messaging
    #
    # Holds a many-to-many relationship between conversations and their participants
    #
    class Participation < ApplicationRecord
      self.table_name = "decidim_messaging_participations"

      belongs_to :conversation,
                 foreign_key: :decidim_conversation_id,
                 class_name: "Decidim::Messaging::Conversation",
                 inverse_of: :participations

      # `inverse_of` is deliberately not declared here, for the same reason as in `Message#sender`: it
      # would propagate participations built through a conversation into the participant's `participations`
      # collection and change the autosave order. The reciprocal `has_many :participations` on
      # `Decidim::UserBaseEntity` is the side that declares `inverse_of`.
      belongs_to :participant,
                 foreign_key: :decidim_participant_id,
                 class_name: "Decidim::UserBaseEntity"

      validates :decidim_conversation_id, uniqueness: { scope: :decidim_participant_id }
    end
  end
end
