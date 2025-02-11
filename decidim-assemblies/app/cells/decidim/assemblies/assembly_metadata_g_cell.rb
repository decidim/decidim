# frozen_string_literal: true

module Decidim
  module Assemblies
    # This cell renders the assembly metadata for g card
    class AssemblyMetadataGCell < Decidim::CardMetadataCell
      alias current_participatory_space model

      private

      def items
        [children_item].compact
      end

      def children_item
        return if children_assemblies_count_for_user.zero?

        {
          text: t("children_item", count: children_assemblies_count_for_user, scope: "layouts.decidim.assemblies.metadata"),
          icon: "government-line"
        }
      end

      def children_assemblies_count_for_user
        @children_assemblies_count_for_user ||= published_children_assemblies.visible_for(current_user).count
      end

      def published_children_assemblies
        @published_children_assemblies ||= model.children.published
      end
    end
  end
end
