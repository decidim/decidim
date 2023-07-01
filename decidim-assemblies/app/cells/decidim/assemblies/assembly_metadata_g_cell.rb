# frozen_string_literal: true

module Decidim
  module Assemblies
    # This cell renders the assembly metadata for g card
    class AssemblyMetadataGCell < Decidim::CardMetadataCell
      alias current_participatory_space model

      private

      def items
        [children_item, assembly_type].compact
      end

      def assembly_type
        return unless has_assembly_type?

        {
          text: translated_attribute(model.assembly_type.title),
          icon: "group-2-line"
        }
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

      def has_assembly_type?
        model.assembly_type.present?
      end
    end
  end
end
