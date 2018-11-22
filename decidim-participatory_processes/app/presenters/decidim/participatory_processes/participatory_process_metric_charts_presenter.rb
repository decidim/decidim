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
        # Remember to change :users for :participants when done
        metric = Decidim.metrics_registry.for(:users) # Temporal use of Users metric to show chart
        content_tag :div, class: "row" do
          render_metrics_descriptive(metric.metric_name,
                                     klass: "column",
                                     graph_klass: "small",
                                     title: I18n.t("decidim.metrics.#{metric.metric_name}.title"),
                                     description: I18n.t("decidim.metrics.#{metric.metric_name}.description"),
                                     data: { ratio: "11:4", axis: true })
        end
      end

      def medium_stats
        # Remember to add :followers metric when done
        safe_join(
          [:proposals, :votes, :endorsements].in_groups_of(2).map do |metrics_group| # Temporal use of metrics to show charts
            content_tag :div, class: "row" do
              safe_join(
                metrics_group.map do |metric_key|
                  next "" if metric_key.blank?
                  render_metrics_descriptive(Decidim.metrics_registry.for(metric_key).metric_name,
                                             klass: "column medium-6",
                                             graph_klass: "small",
                                             title: I18n.t("decidim.metrics.#{metric_key}.title"),
                                             description: I18n.t("decidim.metrics.#{metric_key}.description"),
                                             data: { ratio: "16:9", axis: true })
                end
              )
            end
          end
        )
      end

      def small_stats
        safe_join(
          [:accepted_proposals, :meetings, :debates, :survey_answers, :comments].in_groups_of(3).map do |metrics_group|
            content_tag :div, class: "row" do
              safe_join(
                metrics_group.map do |metric_key|
                  next "" if metric_key.blank?
                  render_metrics_data(Decidim.metrics_registry.for(metric_key).metric_name,
                                      klass: "column medium-4",
                                      ratio: "16:9",
                                      margin: "margin-top: 30px",
                                      graph_klass: "small",
                                      data: { ratio: "16:9" })
                end
              )
            end
          end
        )
      end
    end
  end
end
