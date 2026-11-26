# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    # A suggestion can be upvoted (weight 1) or downvoted (weight -1) by a user.
    class SuggestionVote < CollaborativeTexts::ApplicationRecord
      include Decidim::Authorable

      belongs_to :suggestion, inverse_of: :votes

      validates :suggestion, uniqueness: { scope: :author }
      validates :weight, inclusion: { in: [-1, 1] }

      scope :up, -> { where(weight: 1) }
      scope :down, -> { where(weight: -1) }

      private

      def organization
        suggestion&.organization
      end
    end
  end
end
