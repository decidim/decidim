# frozen_string_literal: true

module Decidim
  # A resource can have an endorsement for each user or group the author/endorser belongs to.
  class Endorsement < ApplicationRecord
    include Decidim::Authorable

    belongs_to :resource,
               polymorphic: true,
               counter_cache: true

    validates :resource_id, uniqueness: { scope: [:resource_type, :author, :user_group] }
    validate :author_and_resource_same_organization

    scope :for_listing, -> { order(:decidim_user_group_id, :created_at) }

    private

    def organization
      resource&.component&.organization
    end

    # Private: check if the resource and the author have the same organization
    def author_and_resource_same_organization
      return if !resource || !author

      errors.add(:resource, :invalid) unless author.organization == resource.organization
    end
  end
end
