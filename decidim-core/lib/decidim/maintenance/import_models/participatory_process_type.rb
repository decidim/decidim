# frozen_string_literal: true

module Decidim
  module Maintenance
    module ImportModels
      class ParticipatoryProcessType < AssemblyType
        self.table_name = "decidim_participatory_process_types"

        def self.root_taxonomy_name = "~ #{I18n.t("decidim.admin.titles.participatory_process_types")}"

        def self.space_manifest = "participatory_processes"

        def resources
          Decidim::ParticipatoryProcess.where(decidim_participatory_process_type_id: id).to_h do |process|
            [process.to_global_id.to_s, process.title[I18n.locale.to_s]]
          end
        end
      end
    end
  end
end
