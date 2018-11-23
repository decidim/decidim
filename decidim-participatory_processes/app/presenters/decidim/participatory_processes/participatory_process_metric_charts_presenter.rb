# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # A presenter to render metrics in pages
    class ParticipatoryProcessMetricChartsPresenter < Decidim::MetricChartsPresenter
      attribute :participatory_process, Decidim::ParticipatoryProcess

      def params
        capture do
          concat(content_tag(:input, nil, type: :hidden, id: :"metrics-space_type", value: participatory_process.class))
          concat(content_tag(:input, nil, type: :hidden, id: :"metrics-space_id", value: participatory_process.id))
        end
      end

      def highlighted
        render_highlighted(Decidim.metrics_registry.filtered(highlight: true, scope: "participatory_process"))
      end

      def not_highlighted
        render_not_highlighted(Decidim.metrics_registry.filtered(highlight: false, scope: "participatory_process"))
      end

      def big_stats
        # Participants
      end

      def medium_stats
        # Proposals
        # Supports
        # Endorsements
        # Followers
      end

      def small_stats
        # Accepted proposals
        # Comments
        # Meetings
        # Debates
        # Answers to surveys
      end
    end
  end
end
