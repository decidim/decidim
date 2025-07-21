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
          text: content_tag("span", t(election.status, scope: "decidim.elections.status"), class: "#{election.status} label")
        }
      end

      def current_date
        @current_date ||= Time.current.to_time
      end

      def start_date
        return if start_at.blank?

        @start_date ||= start_at.to_time
      end

      def end_date
        return if end_at.blank?

        @end_date ||= end_at.to_time
      end

      def progress_text
        if election.published_results? && election.finished?
          return t("published_results", scope: "decidim.metadata.progress",
                                        end_date: l(election.results_published_at.to_time, format: :decidim_short))
        end

        super
      end
    end
  end
end
