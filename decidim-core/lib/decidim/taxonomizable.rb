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

      # finds taxonomizables belonging to a specific taxonomy
      scope :with_taxonomy, ->(taxonomy_id) { includes(:taxonomies).references(:decidim_taxonomies).where("? = ANY(decidim_taxonomies.part_of)", taxonomy_id) }

      # finds taxonomizables belonging to any of the taxonomies specified (or its children)
      scope :with_taxonomies, lambda { |*taxonomy_ids|
        conditions = ["? = ANY(part_of)"] * taxonomy_ids.count
        taxonomies = Decidim::Taxonomy.where(conditions.join(" OR "), *taxonomy_ids.map(&:to_i))
        includes(:taxonomies).joins(:taxonomies).where(decidim_taxonomies: { id: taxonomies })
      }

      # finds taxonomizables belonging to all groups of taxonomies specified, each group is an array of taxonomy ids that are ORed together
      scope :with_any_taxonomies, lambda { |*taxonomy_groups|
        return with_taxonomies(*taxonomy_groups) unless taxonomy_groups.first.is_a?(Array)

        queries = []
        taxonomy_groups.each do |root_id, taxonomy_ids|
          taxonomy_ids = taxonomy_ids.flatten.compact_blank
          next if taxonomy_ids.empty?

          taxonomy_ids = [root_id] if taxonomy_ids.include?("all")

          queries << with_taxonomies(*taxonomy_ids)
        end
        return self if queries.empty?
        return queries.first if queries.count == 1

        subquery = queries.map(&:arel).reduce do |memo, query|
          Arel::Nodes::Intersect.new(memo, query)
        end

        @klass.from(Arel::Nodes::As.new(subquery, Arel.sql(@klass.arel_table.name)))
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
