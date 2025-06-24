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

        def invalid_categorization?(categorization)
          return true if categorization.categorizable.nil?

          return categorization.categorizable.participatory_space != participatory_space if categorization.categorizable.respond_to?(:participatory_space)
          return categorization.categorizable.component.participatory_space != participatory_space if categorization.categorizable.respond_to?(:component)

          false
        end

        def full_name
          return @full_name if defined?(@full_name)

          @full_name = name.dup
          @full_name[I18n.locale.to_s] = "#{parent.name[I18n.locale.to_s]} > #{@full_name[I18n.locale.to_s]}" if parent && parent.parent_id
          @full_name
        end

        def resources
          categorizations.filter_map do |categorization|
            next if invalid_categorization?(categorization)

            [categorization.categorizable.to_global_id.to_s, resource_name(categorization.categorizable)]
          end.to_h
        end

        def taxonomies
          {
            name:,
            origin: to_global_id.to_s,
            children: sub_taxonomy_children,
            resources:
          }
        end

        # original categories are allowed one level more than the current taxonomies
        def sub_taxonomy_children
          subcategories.each_with_object({}) do |subcategory, hash|
            hash[subcategory.name[I18n.locale.to_s]] = {
              name: subcategory.name,
              origin: subcategory.to_global_id.to_s,
              resources: subcategory.resources,
              children: {}
            }

            next unless subcategory.subcategories.any?

            subcategory.subcategories.each do |last_category|
              hash[last_category.full_name[I18n.locale.to_s]] = {
                name: last_category.full_name,
                origin: last_category.to_global_id.to_s,
                resources: last_category.resources,
                children: {}
              }
            end
          end
        end

        def self.children_taxonomies(participatory_space)
          Category.where(participatory_space:, parent_id: nil).to_h do |category|
            [
              category.name[I18n.locale.to_s],
              category.taxonomies
            ]
          end
        end

        def self.children_components(participatory_space)
          participatory_space.components.filter_map do |component|
            # skip components without taxonomies in settings
            next unless component.settings.respond_to?(:taxonomy_filters)

            component.to_global_id.to_s
          end
        end

        def self.all_taxonomies
          participatory_space_classes.each_with_object({}) do |klass, hash|
            klass.where(organization:).each do |participatory_space|
              next unless Category.where(participatory_space:, parent_id: nil).any?

              name = "#{klass.model_name.human}: #{participatory_space.title[I18n.locale.to_s]}"
              hash.merge!(name => {
                            name: { I18n.locale.to_s => name },
                            origin: participatory_space.to_global_id.to_s,
                            resources: {},
                            children: children_taxonomies(participatory_space)
                          })
            end
          end
        end

        def self.all_filters
          participatory_space_classes.each_with_object([]) do |klass, list|
            klass.where(organization:).each do |participatory_space|
              name = "#{klass.model_name.human}: #{participatory_space.title[I18n.locale.to_s]}"
              components = children_components(participatory_space)
              next unless components.any?

              list << {
                name: root_taxonomy_name,
                internal_name: name,
                items: Category.where(participatory_space:).map do |category|
                  names = [name]
                  if category.parent
                    names << if category.parent.parent
                               category.parent.parent.name[I18n.locale.to_s]
                             else
                               category.parent.name[I18n.locale.to_s]
                             end
                  end
                  names << category.full_name[I18n.locale.to_s]
                  names
                end,
                components:
              }
            end
          end
        end
      end
    end
  end
end
