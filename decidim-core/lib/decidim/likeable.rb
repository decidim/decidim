# frozen_string_literal: true

module Decidim
  # This concern contains the logic related with resources that can be liked.
  # Thus, it is expected to be included into a resource that is wanted to be likeable.
  # This resource will have many `Decidim::Like`s.
  module Likeable
    extend ActiveSupport::Concern

    included do
      has_many :likes,
               as: :resource,
               dependent: :destroy,
               counter_cache: "likes_count"

      # Public: Check if the user has liked the resource.
      #
      # Returns Boolean.
      def liked_by?(user)
        likes.where(author: user).any?
      end
    end
  end
end
