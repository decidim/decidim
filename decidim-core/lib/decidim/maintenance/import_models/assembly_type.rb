# frozen_string_literal: true

module Decidim
  module Maintenance
    module ImportModels
      class AssemblyType < ApplicationRecord
        self.table_name = "decidim_assemblies_types"

        def self.root_taxonomy_name = "~ #{I18n.t("decidim.admin.titles.assemblies_types")}"

        def self.space_manifest = "assemblies"

        def name
          title
        end

        def taxonomies
          {
            name:,
            origin: to_global_id.to_s,
            children: {},
            resources:
          }
        end

        def resources
          Decidim::Assembly.where(decidim_assemblies_type_id: id).to_h do |process|
            [process.to_global_id.to_s, process.title[I18n.locale.to_s]]
          end
        end

        def self.all_taxonomies
          all_in_org.to_h { |type| [type.name[I18n.locale.to_s], type.taxonomies] }
        end

        def self.all_filters
          [
            {
              name: root_taxonomy_name,
              space_filter: true,
              space_manifest:,
              items: all_in_org.map { |type| [type.name[I18n.locale.to_s]] },
              components: []
            }
          ]
        end
      end
    end
  end
end
