# frozen_string_literal: true

module Decidim
  # A resource can have a like for each user.
  class Like < ApplicationRecord
    include Decidim::Authorable
    include Decidim::SoftDeletable

    belongs_to :resource,
               polymorphic: true,
               counter_cache: true

    after_restore :reset_like_counter

    validates :resource_id, uniqueness: { scope: [:resource_type, :author] }
    validate :author_and_resource_same_organization

    scope :for_listing, -> { order(:decidim_author_type, :decidim_author_id, :created_at) }

    private

    def organization
      resource&.component&.organization
    end

    # Private: check if the resource and the author have the same organization
    def author_and_resource_same_organization
      return if !resource || !author

      errors.add(:resource, :invalid) unless author.organization == resource.organization
    end

    def reset_like_counter
      return unless resource

      resource.update_columns(likes_count: Decidim::Like.unscoped.where(resource:, deleted_at: nil).count) # rubocop:disable Rails/SkipsModelValidations
    end
  end
end
