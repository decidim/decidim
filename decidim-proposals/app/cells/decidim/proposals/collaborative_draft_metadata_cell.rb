# frozen_string_literal: true

module Decidim
  module Proposals
    # This cell renders metadata for an instance of a CollaborativeDraft
    class CollaborativeDraftMetadataCell < Decidim::CardMetadataCell
      include Decidim::Proposals::ApplicationHelper

      delegate :state, to: :model

      def initialize(*)
        super

        @items.prepend(*collaborative_draft_items)
      end

      private

      def collaborative_draft_items
        [coauthors_item, comments_count_item, likes_count_item, state_item]
      end

      def state_item
        return if state.blank?

        { text: content_tag(:span, humanize_collaborative_draft_state(state), class: "label #{collaborative_drafts_state_class(state)}") }
      end
    end
  end
end
