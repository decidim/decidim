# frozen_string_literal: true

module Decidim
  module Assemblies
    module ContentBlocks
      class ChildrenAssembliesCell < RelatedAssembliesCell
        def related_assemblies
          @related_assemblies ||= resource.children.visible_for(current_user).published.order(weight: :asc)
        end

        def total_count
          related_assemblies.size
        end

        private

        def title
          t("name", scope: "decidim.assemblies.content_blocks.children_assemblies")
        end

        def limit
          model.settings.try(:max_results)
        end
      end
    end
  end
end
