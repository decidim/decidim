# frozen_string_literal: true

module Decidim
  # Represents a hierarchical classification used to organize various entities within the system.
  # Taxonomies are primarily used to categorize and manage different aspects of participatory spaces,
  # such as proposals, assemblies, and other components, within an organization.
  class Taxonomy < ApplicationRecord
    include Decidim::TranslatableResource
    include Decidim::FilterableResource
    include Decidim::Traceable

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
             dependent: :destroy

    has_many :taxonomy_filters, foreign_key: "taxonomy_id", class_name: "Decidim::TaxonomyFilter", dependent: :destroy
    has_many :taxonomizations, foreign_key: "taxonomy_id", class_name: "Decidim::Taxonomization", dependent: :destroy

    validates :name, presence: true

    default_scope { order(:weight) }
  end
end
