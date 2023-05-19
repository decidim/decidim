# frozen_string_literal: true

module Decidim
  module Assemblies
    module ContentBlocks
      class RelatedAssembliesCell < Decidim::ContentBlocks::BaseCell
        def show
          render if total_count.positive?
        end

        def related_assemblies
          @related_assemblies ||=
            resource
            .linked_participatory_space_resources(:assembly, "included_participatory_processes")
            .public_spaces
        end

        def total_count
          related_assemblies.size
        end

        private

        def title
          t("name", scope: "decidim.assemblies.content_blocks.related_assemblies")
        end

        def limit
          model.settings.try(:max_results)
        end
      end
    end
  end
end
