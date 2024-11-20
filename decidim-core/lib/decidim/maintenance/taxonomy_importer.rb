# frozen_string_literal: true

module Decidim
  module Maintenance
    class TaxonomyImporter
      def initialize(organization, model, roots)
        @organization = organization
        @model = model
        @roots = roots
        @result = { taxonomies_created: [], taxonomies_assigned: {}, filters_created: {}, failed_resources: [], failed_components: [] }
      end

      attr_reader :organization, :model, :roots, :result

      def import!
        roots.each do |name, element|
          root = find_taxonomy!(root_taxonomies, name)
          element["taxonomies"].each do |item_name, taxonomy|
            import_taxonomy_item(root, item_name, taxonomy)
          end
          element["filters"].each do |filter_name, filter|
            import_filter(root, filter_name, filter)
          end
        end
      end

      private

      def import_taxonomy_item(parent, name, item)
        taxonomy = find_taxonomy!(parent.children, name)
        taxonomy.update!(name: item["name"]) if item["name"].present?
        item["resources"].each do |object_id, _name|
          apply_taxonomy_to_resource(object_id, taxonomy)
        end
        item["children"].each do |child_name, child|
          import_taxonomy_item(taxonomy, child_name, child)
        end
      end

      def apply_taxonomy_to_resource(object_id, taxonomy)
        resource = GlobalID::Locator.locate(object_id)
        return @result[:failed_resources] << object_id unless resource

        name = taxonomy.name[organization.default_locale]
        unless resource.taxonomies.include?(taxonomy)
          resource.taxonomies << taxonomy
          @result[:taxonomies_assigned][name] ||= []
          @result[:taxonomies_assigned][name] << object_id unless @result[:taxonomies_assigned][name].include?(object_id)
        end
      end

      def import_filter(root, name, data)
        filter = find_taxonomy_filter(root, name) || root.taxonomy_filters.create!(space_filter: data["space_filter"], space_manifest: data["space_manifest"])

        data["items"].each do |item_names|
          taxonomy = root
          item_names.each do |item_name|
            taxonomy = find_taxonomy!(taxonomy.children, item_name)
          end
          next if filter.filter_items.exists?(taxonomy_item: taxonomy)

          filter.filter_items.create!(taxonomy_item: taxonomy) do
            @result[:filters_created][name] ||= []
            @result[:filters_created][name] << item_names.join(" > ")
          end
        end

        data["components"].each do |component_id|
          component = GlobalID::Locator.locate(component_id)
          if component
            component.update!(settings: { taxonomy_filters: [filter.id.to_s] })
          else
            @result[:failed_components] << component_id
          end
        end
      end

      def find_taxonomy(association, name)
        association.find_by("name->>? = ?", organization.default_locale, name)
      end

      def find_taxonomy!(association, name)
        find_taxonomy(association, name) || create_taxonomy!(association, name)
      end

      def create_taxonomy!(association, name)
        association.create!(name: { organization.default_locale => name }, organization:) do
          @result[:taxonomies_created] << name
        end
      end

      def find_taxonomy_filter(root_taxonomy, name)
        root_taxonomy.taxonomy_filters.all.detect { |filter| filter.internal_name[organization.default_locale] == name }
      end

      def root_taxonomies
        organization.taxonomies.roots
      end
    end
  end
end
