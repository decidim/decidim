# frozen_string_literal: true

module Decidim
  # A ResourceLink allows linking resources (other entities in Decidim) between
  # them without them having to know each other.
  #
  # In order to group the relations between resources you need to specify a name.
  #
  # Some examples could be: proposals that have been created in a meeting or
  # projects that are a result of merging diffrent proposals.
  class ResourceLink < ApplicationRecord
    belongs_to :from, polymorphic: true
    belongs_to :to, polymorphic: true

    validates :name, presence: true, uniqueness: { scope: [:from, :to] }

    validate :same_organization

    private

    def same_organization
      return if from.try(:organization) == to.try(:organization)

      errors.add(:from, :invalid)
      errors.add(:to, :invalid)
    end
  end
end
