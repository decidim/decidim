# frozen_string_literal: true

module Decidim
  class Coauthorship < ApplicationRecord
    include Decidim::Authorable

    belongs_to :coauthorable, polymorphic: true, counter_cache: true

    validates :coauthorable, presence: true

    after_commit :author_is_follower, on: [:create]

    def identity
      user_group || author
    end

    private

    # As it is used to validate by comparing to author.organization
    # @returns The Organization for the Coauthorable
    def organization
      coauthorable&.organization
    end

    def author_is_follower
      return unless author.is_a?(Decidim::User)
      return unless coauthorable.is_a?(Decidim::Followable)

      Decidim::Follow.find_or_create_by!(followable: coauthorable, user: author)
    end
  end
end
