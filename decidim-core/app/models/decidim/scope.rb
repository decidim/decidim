# frozen_string_literal: true

module Decidim
  # Scopes are used in some entities through Decidim to help users know which is
  # the scope of a participatory process.
  # (i.e. does it affect the whole city or just a district?)
  class Scope < ApplicationRecord
    belongs_to :organization,
               foreign_key: "decidim_organization_id",
               class_name: "Decidim::Organization",
               inverse_of: :scopes

    belongs_to :scope_type,
               foreign_key: "scope_type_id",
               class_name: "Decidim::ScopeType",
               inverse_of: :scopes,
               optional: true

    belongs_to :parent,
               foreign_key: "parent_id",
               class_name: "Decidim::Scope",
               inverse_of: :children,
               optional: true

    has_many :children,
             foreign_key: "parent_id",
             class_name: "Decidim::Scope",
             inverse_of: :parent

    before_validation :update_part_of, on: :update

    validates :name, :code, :organization, presence: true
    validates :code, uniqueness: { scope: :organization }
    validate :forbid_cycles

    after_create_commit :create_part_of

    # Scope to return only the top level scopes.
    #
    # Returns an ActiveRecord::Relation.
    def self.top_level
      where parent_id: nil
    end

    def descendants
      organization.scopes.where("? = ANY(decidim_scopes.part_of)", id)
    end

    # Gets the scopes from the part_of list
    #
    # Returns an ActiveRecord::Relation.
    def part_of_scopes
      organization.scopes.where(id: part_of)
    end

    private

    def forbid_cycles
      errors.add(:parent_id, :cycle_detected) if parent && parent.part_of.include?(id)
    end

    def create_part_of
      self[:part_of] = calculate_part_of
      save if changed?
    end

    def update_part_of
      self[:part_of] = calculate_part_of
    end

    def calculate_part_of
      if parent
        [id] + parent.part_of
      else
        [id]
      end
    end
  end
end
