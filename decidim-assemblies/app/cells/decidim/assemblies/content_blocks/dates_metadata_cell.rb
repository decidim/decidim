# frozen_string_literal: true

module Decidim
  module Assemblies
    module ContentBlocks
      class DatesMetadataCell < Decidim::ContentBlocks::ParticipatorySpaceMetadataCell
        private

        def metadata_items
          %w(creation_date created_by included_at closing_date)
        end

        def space_presenter
          AssemblyPresenter
        end

        def translations_scope
          "decidim.assemblies.assemblies.description"
        end
      end
    end
  end
end
