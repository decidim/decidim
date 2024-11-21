# frozen_string_literal: true

module Decidim
  module Maintenance
    module ImportModels
      class Category < ApplicationRecord
        resource_models []
        participatory_space_models ["Decidim::Assembly", "Decidim::ParticipatoryProcess", "Decidim::Conference", "Decidim::Initiative"]

        self.table_name = "decidim_categories"
        belongs_to :participatory_space, foreign_key: "decidim_participatory_space_id", foreign_type: "decidim_participatory_space_type", polymorphic: true
        has_many :subcategories, foreign_key: "parent_id", class_name: "Decidim::Maintenance::ImportModels::Category", dependent: :destroy, inverse_of: :parent
        belongs_to :parent, class_name: "Decidim::Maintenance::ImportModels::Category", inverse_of: :subcategories, optional: true
        has_many :categorizations, foreign_key: "decidim_category_id", class_name: "Decidim::Maintenance::ImportModels::Categorization", dependent: :destroy

        def self.root_taxonomy_name = "~ #{I18n.t("decidim.admin.categories.index.categories_title")}"

        def resources
          normal_resources = categorizations.to_h do |categorization|
            [categorization.categorizable.to_global_id.to_s, resource_name(categorization.categorizable)]
          end

          metrics = Decidim::Metric.where(decidim_category_id: id).to_h do |metric|
            [metric.to_global_id.to_s, metric.to_s]
          end

          normal_resources.merge(metrics)
        end

        def taxonomies
          {
            name:,
            children: subcategories.to_h do |subcategory|
              [
                subcategory.name[I18n.locale.to_s],
                subcategory.taxonomies
              ]
            end,
            resources:
          }
        end

        def self.all_taxonomies
          participatory_space_classes.each_with_object({}) do |klass, hash|
            klass.where(organization:).each do |participatory_space|
              hash.merge!(Category.where(participatory_space:).to_h { |category| [category.name[I18n.locale.to_s], category.taxonomies] })
            end
          end
        end

        def self.all_filters
          []
        end
      end
    end
  end
end
