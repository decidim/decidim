# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # A presenter to render metrics in ParticipatoryProcesses statistics page
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
        # metric = Decidim.metrics_registry.for(:participants)
        metric = Decidim.metrics_registry.for(:users) # Temporal use of Users metric to show chart
        render_metrics_data(metric.metric_name, klass: "column medium-12")
      end

      def medium_stats
        safe_join(
          # %i{proposals supports endorsements followers}.map do |metric|
          [:proposals, :accepted_proposals, :votes, :meetings].map do |metric_key| # Temporal use of metrics to show charts
            render_metrics_data(Decidim.metrics_registry.for(metric_key).metric_name, klass: "column medium-6")
          end
        )
      end

      def small_stats
        safe_join(
          # %i{accepted_proposals comments meetings debates survey_answers}.map do |metric_key|
          [:participatory_processes, :assemblies, :comments, :results].map do |metric_key| # Temporal use of metrics to show charts
            render_metrics_data(Decidim.metrics_registry.for(metric_key).metric_name, klass: "column medium-4")
          end
        )
      end
    end
  end
end
