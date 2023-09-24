# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module ContentBlocks
      class MetadataCell < Decidim::ContentBlocks::ParticipatorySpaceMetadataCell
        private

        def metadata_items
          %w(participatory_scope target participatory_structure area_name meta_scope local_area developer_group)
        end

        def space_presenter
          ParticipatoryProcessPresenter
        end

        def translations_scope
          "decidim.participatory_processes.participatory_processes.description"
        end
      end
    end
  end
end
