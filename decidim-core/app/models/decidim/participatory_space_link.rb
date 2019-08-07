# frozen_string_literal: true

module Decidim
  class ParticipatorySpaceLink < ApplicationRecord
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
