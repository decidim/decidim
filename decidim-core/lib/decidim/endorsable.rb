# frozen_string_literal: true

module Decidim
  # This concern contains the logic related with resources that can be endorsed.
  # Thus, it is expected to be included into a resource that is wanted to be endorsable.
  # This resource will have many `Decidim::Endorsement`s.
  module Endorsable
    extend ActiveSupport::Concern

    included do
      has_many :endorsements,
               as: :resource,
               dependent: :destroy,
               counter_cache: "endorsements_count"

      # Public: Check if the user has endorsed the resource.
      #
      # Returns Boolean.
      def endorsed_by?(user)
        endorsements.where(author: user).any?
      end
    end
  end
end
