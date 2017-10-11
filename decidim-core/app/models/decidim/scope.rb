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

    # Gets the scopes from the part_of list in descending order (first the top level scope, last itself)
    #
    # Returns an array of Scope objects
    def part_of_scopes
      organization.scopes.where(id: part_of).sort { |s1, s2| part_of.index(s2.id) <=> part_of.index(s1.id) }
    end

    private

    def forbid_cycles
      return unless parent
      errors.add(:parent_id, :cycle_detected) if parent.part_of.include?(id)
    end

    def create_part_of
      build_part_of
      save if changed?
    end

    def update_part_of
      build_part_of
    end

    def build_part_of
      if parent
        part_of.clear.append(id).concat(parent.reload.part_of)
      else
        part_of.clear.append(id)
      end
    end
  end
end
