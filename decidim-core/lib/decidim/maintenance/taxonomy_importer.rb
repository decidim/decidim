# frozen_string_literal: true

module Decidim
  module Maintenance
    class TaxonomyImporter
      def initialize(organization, roots)
        @organization = organization
        @roots = roots
        @result = { taxonomy_map: {}, taxonomies_created: [], taxonomies_assigned: {}, filters_created: {}, components_assigned: {}, failed_resources: [], failed_components: [] }
      end

      attr_reader :organization, :roots, :result

      def import!(&)
        roots.each do |name, element|
          root = find_taxonomy!(root_taxonomies, name)
          element["taxonomies"].each do |item_name, taxonomy|
            import_taxonomy_item(root, item_name, taxonomy)
            yield "Taxonomy imported", item_name if block_given?
          end
          element["filters"].each do |filter|
            import_filter(root, filter)
            yield "Filter imported", filter["name"] if block_given?
          end
        end
      end

      private

      def import_taxonomy_item(parent, name, item)
        taxonomy = find_taxonomy!(parent.children, name)
        taxonomy.update!(name: item["name"]) if item["name"].present?
        result[:taxonomy_map][taxonomy.id] = item["origin"]

        item["resources"].each do |object_id, _name|
          apply_taxonomy_to_resource(object_id, taxonomy)
        end
        item["children"].each do |child_name, child|
          import_taxonomy_item(taxonomy, child_name, child)
        end
      rescue ActiveRecord::RecordInvalid => e
        abort "Error importing taxonomy item #{name} with parent #{parent.name} (#{e.message})"
      end

      def apply_taxonomy_to_resource(object_id, taxonomy)
        resource = GlobalID::Locator.locate(object_id)
        return result[:failed_resources] << object_id unless resource

        name = taxonomy.name[organization.default_locale]

        begin
          if resource.respond_to? :taxonomy
            resource.update(decidim_taxonomy_id: taxonomy.id)
          else
            return if resource.taxonomies.include?(taxonomy)

            resource.taxonomies << taxonomy
          end
          result[:taxonomies_assigned][name] ||= []
          result[:taxonomies_assigned][name] << object_id unless result[:taxonomies_assigned][name].include?(object_id)
        rescue ActiveRecord::RecordInvalid
          result[:failed_resources] << object_id
        end
      end

      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/PerceivedComplexity
      def import_filter(root, data)
        filter = find_taxonomy_filter!(root, data)

        data["items"].each do |item_names|
          taxonomy = root
          item_names.each do |item_name|
            taxonomy = find_taxonomy!(taxonomy.children, item_name)
          end
          next if filter.filter_items.exists?(taxonomy_item: taxonomy)

          filter.filter_items.create!(taxonomy_item: taxonomy) do
            result[:filters_created][filter.internal_name[organization.default_locale]] ||= []
            result[:filters_created][filter.internal_name[organization.default_locale]] << item_names.join(" > ")
          end
        end

        data["components"].each do |component_id|
          component = GlobalID::Locator.locate(component_id)
          if component
            begin
              component.update!(settings: { taxonomy_filters: [filter.id.to_s] })
              result[:components_assigned][filter.internal_name[organization.default_locale]] ||= []
              result[:components_assigned][filter.internal_name[organization.default_locale]] << component_id
            rescue ActiveRecord::RecordInvalid
              result[:failed_components] << component_id
            end
          else
            result[:failed_components] << component_id
          end
        end
      rescue ActiveRecord::RecordInvalid => e
        abort "Error importing filter #{data} for root taxonomy #{root.name} (#{e.message})"
      end
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/PerceivedComplexity

      def find_taxonomy(association, name)
        association.find_by("name->>? = ?", organization.default_locale, name)
      end

      def find_taxonomy!(association, name)
        find_taxonomy(association, name) || create_taxonomy!(association, name)
      end

      def create_taxonomy!(association, name)
        association.create!(name: { organization.default_locale => name }, organization:) do
          result[:taxonomies_created] << name
        end
      rescue ActiveRecord::RecordInvalid => e
        abort "Error creating taxonomy #{name} with parent #{association.new.parent.name[organization.default_locale]} (#{e.message})"
      end

      def find_taxonomy_filter!(root_taxonomy, data)
        name = data["internal_name"] || data["name"]
        attributes = {
          "participatory_space_manifests" => data["participatory_space_manifests"] || []
        }
        attributes["internal_name"] = { organization.default_locale => data["internal_name"] } if data["internal_name"]
        attributes["name"] = { organization.default_locale => data["public_name"] } if data["public_name"]

        find_taxonomy_filter(root_taxonomy, name:, participatory_space_manifests: data["participatory_space_manifests"]) || root_taxonomy.taxonomy_filters.create!(attributes)
      end

      def find_taxonomy_filter(root_taxonomy, name:, participatory_space_manifests:)
        root_taxonomy.taxonomy_filters.all.detect do |filter|
          filter.internal_name[organization.default_locale] == name && filter.participatory_space_manifests == participatory_space_manifests
        end
      end

      def root_taxonomies
        organization.taxonomies.roots
      end
    end
  end
end
