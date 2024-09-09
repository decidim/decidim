# frozen_string_literal: true

module Decidim
  # Represents a hierarchical classification used to organize various entities within the system.
  # Taxonomies are primarily used to categorize and manage different aspects of participatory spaces,
  # such as proposals, assemblies, and other components, within an organization.
  class Taxonomy < ApplicationRecord
    include Decidim::TranslatableResource
    include Decidim::FilterableResource
    include Decidim::Traceable

    before_create :set_default_weight

    translatable_fields :name

    belongs_to :organization,
               foreign_key: "decidim_organization_id",
               class_name: "Decidim::Organization",
               inverse_of: :taxonomies

    belongs_to :parent,
               class_name: "Decidim::Taxonomy",
               counter_cache: :children_count,
               inverse_of: :children,
               optional: true

    has_many :children,
             foreign_key: "parent_id",
             class_name: "Decidim::Taxonomy",
             inverse_of: :parent,
             dependent: :destroy

    has_many :taxonomizations, class_name: "Decidim::Taxonomization", dependent: :destroy
    has_many :taxonomy_filters, foreign_key: "root_taxonomy_id", class_name: "Decidim::TaxonomyFilter", dependent: :destroy
    has_many :taxonomy_filter_items, foreign_key: "taxonomy_item_id", class_name: "Decidim::TaxonomyFilterItem", dependent: :destroy

    validates :name, presence: true
    validates :weight, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
    validate :validate_max_children_levels

    default_scope { order(:weight) }

    ransacker_i18n :name

    scope :search_by_name, lambda { |name|
      where("name ->> ? ILIKE ?", I18n.locale.to_s, "%#{name}%")
    }

    def self.log_presenter_class_for(_log)
      Decidim::AdminLog::TaxonomyPresenter
    end

    def self.ransackable_scopes(_auth_object = nil)
      [:search_by_name]
    end

    def self.ransackable_attributes(_auth_object = nil)
      %w(id name parent_id)
    end

    def self.ransackable_associations(_auth_object = nil)
      %w(children)
    end

    def translated_name
      Decidim::TaxonomyPresenter.new(self).translated_name
    end

    def root_taxonomy
      @root_taxonomy ||= root? ? self : parent.root_taxonomy
    end

    def parent_ids
      @parent_ids ||= parent_id ? parent.parent_ids + [parent_id] : []
    end

    def root? = parent_id.nil?

    def removable?
      true
    end

    def all_children
      @all_children ||= children.flat_map { |child| [child] + child.all_children }
    end

    private

    def set_default_weight
      return if weight.present?

      self.weight = Taxonomy.where(parent_id:).count
    end

    def validate_max_children_levels
      return unless parent_id

      errors.add(:base, :invalid) if parent_ids.size > 3
    end
  end
end
