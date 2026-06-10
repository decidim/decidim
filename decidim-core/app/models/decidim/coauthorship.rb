# frozen_string_literal: true

module Decidim
  class Coauthorship < ApplicationRecord
    include Decidim::Authorable

    acts_as_paranoid

    belongs_to :coauthorable, polymorphic: true, counter_cache: true

    after_commit :author_is_follower, on: [:create]
    after_restore :reset_coauthorable_counter

    def identity
      author
    end

    # Reports the mapped resource type for authorization transfers.
    #
    # @return [String] The resource type as string (i.e. its class name).
    def mapped_resource_type
      coauthorable_type
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

    def reset_coauthorable_counter
      return unless coauthorable

      coauthorable.class.unscoped.reset_counters(coauthorable.id, :coauthorships)
    end
  end
end
