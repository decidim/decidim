# frozen_string_literal: true

module Decidim
  module Maintenance
    class TaxonomyImporter
      def initialize(organization, model, roots)
        @organization = organization
        @model = model
        @roots = roots
        @result = { created: [], assigned: {} }
      end

      attr_reader :organization, :model, :roots, :result

      def import!
        roots.each do |name, element|
          root = find_taxonomy!(root_taxonomies, name)
          element["taxonomies"].each do |item_name, taxonomy|
            import_taxonomy_item(root, item_name, taxonomy)
          end
          # puts element["filters"]
        end
      end

      private

      def import_taxonomy_item(parent, name, item)
        taxonomy = find_taxonomy!(parent.children, name)
        item["resources"].each do |object_id, _name|
          apply_taxonomy_to_resource(object_id, taxonomy)
        end
        item["children"].each do |child_name, child|
          import_taxonomy_item(taxonomy, child_name, child)
        end
      end

      def apply_taxonomy_to_resource(object_id, taxonomy)
        resource = GlobalID::Locator.locate(object_id)
        name = taxonomy.name[organization.default_locale]
        unless resource.taxonomies.include?(taxonomy)
          resource.taxonomies << taxonomy
          @result[:assigned][name] ||= []
          @result[:assigned][name] << object_id unless @result[:assigned][name].include?(object_id)
        end
      end

      def find_taxonomy!(association, name)
        association.find_by("name->>? = ?", organization.default_locale, name) || create_taxonomy!(association, name)
      end

      def create_taxonomy!(association, name)
        association.create!(name: { organization.default_locale => name }, organization:) do
          @result[:created] << name
        end
      end

      def root_taxonomies
        organization.taxonomies.roots
      end
    end
  end
end
