# frozen_string_literal: true

module Decidim
  # Scopes are used in some entities through Decidim to help users know which is
  # the scope of a participatory process.
  # (i.e. does it affect the whole city or just a district?)
  class Scope < ApplicationRecord
    include Decidim::Traceable
    include Decidim::Loggable
    include Decidim::TranslatableResource
    include Decidim::FilterableResource

    translatable_fields :name

    belongs_to :organization,
               foreign_key: "decidim_organization_id",
               class_name: "Decidim::Organization",
               inverse_of: :scopes

    belongs_to :scope_type,
               class_name: "Decidim::ScopeType",
               inverse_of: :scopes,
               optional: true

    belongs_to :parent,
               class_name: "Decidim::Scope",
               inverse_of: :children,
               optional: true

    has_many :children,
             foreign_key: "parent_id",
             class_name: "Decidim::Scope",
             inverse_of: :parent,
             dependent: :destroy

    before_validation :update_part_of, on: :update

    validates :name, :code, presence: true
    validates :code, uniqueness: { scope: :organization }
    validate :forbid_cycles

    after_create_commit :create_part_of

    # Scope to return only the top level scopes.
    #
    # Returns an ActiveRecord::Relation.
    def self.top_level(organization_id = nil)
      query = where parent_id: nil
      query = query.where(decidim_organization_id: organization_id) if organization_id
      query
    end

    def self.log_presenter_class_for(_log)
      Decidim::AdminLog::ScopePresenter
    end

    def descendants
      @descendants ||= organization.scopes.where("? = ANY(decidim_scopes.part_of)", id)
    end

    def ancestor_of?(scope)
      scope && scope.part_of.member?(id)
    end

    # Gets the scopes from the part_of list in descending order (first the top level scope, last itself)
    #
    # root - The root scope to start retrieval. If present, ignores top level scopes until reaching the root scope.
    #
    # Returns an array of Scope objects
    def part_of_scopes(root = nil)
      scope_ids = part_of
      scope_ids.select! { |id| id == root.id || !root.part_of.member?(id) } if root
      organization.scopes.where(id: scope_ids).sort { |s1, s2| part_of.index(s2.id) <=> part_of.index(s1.id) }
    end

    # Allow ransacker to search for a key in a hstore column (`name`.`en`)
    ransacker_i18n :name

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
