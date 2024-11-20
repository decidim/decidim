# frozen_string_literal: true

module Decidim
  module Maintenance
    class AssemblyType < ApplicationRecord
      self.table_name = "decidim_assemblies_types"

      def name
        title
      end

      def taxonomies
        {
          name:,
          children: [],
          resources:
        }
      end

      def resources
        Decidim::Assembly.where(decidim_assemblies_type_id: id).to_h do |process|
          [process.to_global_id.to_s, process.title[I18n.locale.to_s]]
        end
      end

      def self.to_taxonomies
        {
          I18n.t("decidim.admin.titles.assemblies_types") => to_a
        }
      end

      def self.to_a
        {
          taxonomies: all_in_org.to_h { |type| [type.name[I18n.locale.to_s], type.taxonomies] },
          filters: {
            I18n.t("decidim.admin.titles.assemblies_types") => {
              space_filter: true,
              space_manifest: "assemblies",
              items: all_in_org.map { |type| [type.name[I18n.locale.to_s]] },
              components: []
            }
          }
        }
      end
    end
  end
end
