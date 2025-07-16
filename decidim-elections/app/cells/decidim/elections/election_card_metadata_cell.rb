# frozen_string_literal: true

module Decidim
  module Elections
    # This cell renders metadata for an instance of a Meeting
    class ElectionCardMetadataCell < Decidim::CardMetadataCell
      include Decidim::LayoutHelper
      include ActionView::Helpers::DateHelper

      alias election model

      delegate :start_at, :end_at, to: :election

      def initialize(*)
        super

        @items.prepend(*election_items)
      end

      def election_items
        [label, progress_item]
      end

      def label
        {
          text: content_tag("span", t(election.status, scope: "decidim.elections.elections.show"), class: "#{election.status} label")
        }
      end

      def start_date
        return if election.try(:start_at).blank?

        @start_date ||= election.start_at.to_time
      end

      def end_date
        return if election.try(:end_at).blank?

        @end_date ||= election.end_at.to_time
      end
    end
  end
end
