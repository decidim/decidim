# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # A concern with the components needed when you want a model to have taxonomies.
  #
  # The including model needs to implement the following interface:
  #
  #  @abstract  method that gives an associated organization
  #  @method organization
  #    @return [Decidim::Organization]
  #
  module Taxonomizable
    extend ActiveSupport::Concern

    included do
      has_many :taxonomizations, as: :taxonomizable, class_name: "Decidim::Taxonomization", dependent: :destroy
      has_many :taxonomies, through: :taxonomizations

      validate :no_root_taxonomies
      validate :taxonomies_belong_to_organization

      scope :with_taxonomy, ->(taxonomy_id) { includes(:taxonomy).references(:decidim_taxonomies).where("? = ANY(decidim_taxonomies.part_of)", taxonomy_id) }

      scope :with_any_taxonomy, lambda { |*original_taxonomy_ids|
        taxonomy_ids = original_taxonomy_ids.flatten
        return self if taxonomy_ids.include?("all")

        clean_taxonomy_ids = taxonomy_ids

        conditions = []
        conditions << "#{table_name}.decidim_taxonomy_id IS NULL" if clean_taxonomy_ids.delete("global")
        conditions.concat(["? = ANY(decidim_taxonomies.part_of)"] * clean_taxonomy_ids.count) if clean_taxonomy_ids.any?

        includes(:taxonomies).references(:decidim_taxonomies).where(Arel.sql(conditions.join(" OR ")).to_s, *clean_taxonomy_ids.map(&:to_i))
      }

      private

      def no_root_taxonomies
        return unless taxonomies.any?(&:root?)

        errors.add(:taxonomies, :invalid)
      end

      def taxonomies_belong_to_organization
        return if taxonomies.all? { |taxonomy| taxonomy.organization == organization }

        errors.add(:taxonomies, :invalid)
      end
    end
  end
end
