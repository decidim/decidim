# frozen_string_literal: true

module Decidim
  module Maintenance
    class ParticipatoryProcessType < ApplicationRecord
      self.table_name = "decidim_participatory_process_types"

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
        Decidim::ParticipatoryProcess.where(decidim_participatory_process_type_id: id).to_h do |process|
          [process.to_global_id.to_s, process.title[I18n.locale.to_s]]
        end
      end

      def self.to_taxonomies
        {
          I18n.t("decidim.admin.titles.participatory_process_types") => to_h
        }
      end

      def self.to_h
        {
          taxonomies: all_in_org.to_h { |type| [type.name[I18n.locale.to_s], type.taxonomies] },
          filters: [
            {
              name: I18n.t("decidim.admin.titles.participatory_process_types"),
              space_filter: true,
              space_manifest: "participatory_processes",
              items: all_in_org.map { |type| [type.name[I18n.locale.to_s]] },
              components: []
            }
          ]
        }
      end
    end
  end
end
