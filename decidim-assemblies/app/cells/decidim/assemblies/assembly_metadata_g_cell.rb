# frozen_string_literal: true

module Decidim
  module Assemblies
    # This cell renders the assembly metadata for g card
    class AssemblyMetadataGCell < Decidim::CardMetadataCell
      alias current_participatory_space model

      private

      def items
        [type_item, children_item, upcoming_meeting_item].compact
      end

      def upcoming_meeting_item
        {
          hook: :upcoming_meeting_for_card,
          icon: resource_type_icon_key("Decidim::Meetings::Meeting")
        }
      end

      def type_item
        return unless has_meta_scope?

        {
          text: translated_attribute(model.meta_scope),
          icon: "group-2-line"
        }
      end

      def children_item
        return if children_assemblies_count_for_user.zero?

        {
          text: t("children_item", count: children_assemblies_count_for_user, scope: "layouts.decidim.assemblies.metadata"),
          icon: "bubble-chart-line"
        }
      end

      def children_assemblies_count_for_user
        @children_assemblies_count_for_user ||= published_children_assemblies.visible_for(current_user).count
      end

      def published_children_assemblies
        @published_children_assemblies ||= model.children.published
      end

      def has_meta_scope?
        model.meta_scope.present?
      end
    end
  end
end
