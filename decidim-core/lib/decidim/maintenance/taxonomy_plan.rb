# frozen_string_literal: true

module Decidim
  module Maintenance
    class TaxonomyPlan
      def initialize(organization, models, importer: TaxonomyImporter)
        @organization = organization
        @models = models
        @importer = importer
      end

      attr_reader :organization, :models, :importer

      def import(data, &)
        data["imported_taxonomies"].each do |model_name, taxonomies|
          klass = importer.new(organization, taxonomies)
          if block_given?
            yield klass, model_name
          else
            klass.import!
          end
        end
      end

      def to_json(*_args, &)
        I18n.with_locale(organization.default_locale) do
          JSON.pretty_generate(to_h(&))
        end
      end

      def to_h(&)
        {
          organization: {
            id: organization.id,
            locale: organization.default_locale,
            host: organization.host,
            name: translate(organization.name)
          },
          existing_taxonomies:,
          imported_taxonomies: imported_taxonomies(&)
        }
      end

      def imported_taxonomies
        return @imported_taxonomies if defined?(@imported_taxonomies)

        @imported_taxonomies = {}
        models.map do |model|
          yield model if block_given?
          @imported_taxonomies[model.table_name] = model.with(organization).to_taxonomies
        end
        @imported_taxonomies
      end

      def existing_taxonomies
        organization.taxonomies.roots.to_h do |root|
          [
            translate(root.name),
            root.children.to_h do |taxonomy|
              [
                translate(taxonomy.name),
                taxonomy.children.map do |child|
                  translate(child.name)
                end
              ]
            end
          ]
        end
      end

      private

      def translate(translatable)
        return translatable[organization.default_locale.to_s]
      end
    end
  end
end
