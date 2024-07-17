# frozen_string_literal: true

module Decidim
  # Represents a hierarchical classification used to organize various entities within the system.
  # Taxonomies are primarily used to categorize and manage different aspects of participatory spaces,
  # such as proposals, assemblies, and other components, within an organization.
  class Taxonomy < ApplicationRecord
    include Decidim::TranslatableResource
    include Decidim::FilterableResource
    include Decidim::Traceable

    after_initialize :set_default_weight

    translatable_fields :name

    belongs_to :organization,
               foreign_key: "decidim_organization_id",
               class_name: "Decidim::Organization",
               inverse_of: :taxonomies

    belongs_to :parent,
               class_name: "Decidim::Taxonomy",
               optional: true

    has_many :children,
             foreign_key: "parent_id",
             class_name: "Decidim::Taxonomy",
             dependent: :restrict_with_error

    has_many :taxonomy_filters, class_name: "Decidim::TaxonomyFilter", dependent: :restrict_with_error
    has_many :taxonomizations, class_name: "Decidim::Taxonomization", dependent: :restrict_with_error

    validates :name, presence: true
    validates :weight, numericality: { greater_than_or_equal_to: 0 }
    validate :validate_children_levels

    default_scope { order(:weight) }

    ransacker_i18n :name

    def self.ransackable_scopes(_auth_object = nil)
      [:search_by_name]
    end

    scope :search_by_name, lambda { |name|
      where("name ->> ? ILIKE ?", I18n.locale.to_s, "%#{name}%")
    }

    def root_taxonomy
      @root_taxonomy ||= root? ? self : parent.root_taxonomy
    end

    def parent_ids
      @parent_ids ||= parent_id ? parent.parent_ids + [parent_id] : []
    end

    def root? = parent_id.nil?

    def removable?
      !children.exists? && !taxonomy_filters.exists? && !taxonomizations.exists?
    end

    private

    def set_default_weight
      self.weight ||= Taxonomy.where(parent_id:).count
    end

    def validate_children_levels
      return unless parent_id

      errors.add(:base, :invalid) if parent_ids.size > 2
    end
  end
end
