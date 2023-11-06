# frozen_string_literal: true

module Decidim
  module Initiatives
    # This cell renders the assembly metadata for g card
    class InitiativeMetadataGCell < Decidim::CardMetadataCell
      include Cell::ViewModel::Partial
      include Decidim::Initiatives::InitiativeHelper

      alias current_initiative resource
      alias initiative resource

      def initialize(*)
        super

        @items.prepend(*initiative_items)
      end

      private

      def initiative_items
        [dates_item, progress_bar_item, state_item].compact
      end

      def start_date
        initiative.signature_start_date
      end

      def end_date
        initiative.signature_end_date
      end

      def state_item
        return if initiative.state.blank?

        {
          text: content_tag(
            :span,
            t(initiative.state, scope: "decidim.initiatives.show.badge_name"),
            class: "label #{metadata_badge_css_class(initiative.state)} initiative-status"
          )
        }
      end

      def progress_bar_item
        return if %w(created validating discarded).include?(initiative.state)

        type_scope = initiative.votable_initiative_type_scopes[0]

        {
          cell: "decidim/progress_bar",
          args: [initiative.supports_count_for(type_scope.scope), {
            total: type_scope.supports_required,
            element_id: "initiative-#{initiative.id}-votes-count",
            class: "progress-bar__sm"
          }],
          icon: nil
        }
      end
    end
  end
end
