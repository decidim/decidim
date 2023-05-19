# frozen_string_literal: true

module Decidim
  module Assemblies
    module ContentBlocks
      class MetadataCell < Decidim::ContentBlocks::ParticipatorySpaceMetadataCell
        private

        def metadata_items = %w(participatory_scope target participatory_structure area_name meta_scope local_area developer_group duration closing_date)

        def space_presenter = AssemblyPresenter

        def translations_scope = "decidim.assemblies.assemblies.description"
      end
    end
  end
end
