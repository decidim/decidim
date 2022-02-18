# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # A presenter to render metrics in ParticipatoryProcesses statistics page
    class ParticipatoryProcessMetricChartsPresenter < Decidim::MetricChartsPresenter
      delegate :hidden_field_tag, :link_to, :capture, to: :view_context

      def participatory_process
        __getobj__.fetch(:participatory_process)
      end

      def params
        capture do
          concat(hidden_field_tag(:metrics_space_type, participatory_process.class.name, id: :"metrics-space_type"))
          concat(hidden_field_tag(:metrics_space_id, participatory_process.id, id: :"metrics-space_id"))
        end
      end

      def highlighted
        render_highlighted(Decidim.metrics_registry.filtered(highlight: true, scope: "participatory_process"))
      end

      def not_highlighted
        render_not_highlighted(Decidim.metrics_registry.filtered(highlight: false, scope: "participatory_process"))
      end

      def big_stats
        safe_join(
          Decidim.metrics_registry.filtered(scope: "participatory_process", block: "big", sort: true).map do |metric_manifest|
            content_tag :div, class: "row" do
              render_metrics_descriptive(metric_manifest.metric_name,
                                         klass: "column",
                                         graph_klass: "small",
                                         title: I18n.t("decidim.metrics.#{metric_manifest.metric_name}.title"),
                                         description: I18n.t("decidim.metrics.#{metric_manifest.metric_name}.description"),
                                         download: true,
                                         data: { ratio: "11:4", axis: true })
            end
          end
        )
      end

      def medium_stats
        safe_join(
          Decidim.metrics_registry.filtered(scope: "participatory_process", block: "medium", sort: true).in_groups_of(2).map do |metrics_group|
            content_tag :div, class: "row" do
              safe_join(
                metrics_group.map do |metric_manifest|
                  next "" if metric_manifest.blank?

                  render_metrics_descriptive(metric_manifest.metric_name,
                                             klass: "column medium-6",
                                             graph_klass: "small",
                                             title: I18n.t("decidim.metrics.#{metric_manifest.metric_name}.title"),
                                             description: I18n.t("decidim.metrics.#{metric_manifest.metric_name}.description"),
                                             download: true,
                                             data: { ratio: "16:9", axis: true })
                end
              )
            end
          end
        )
      end

      def small_stats
        safe_join(
          Decidim.metrics_registry.filtered(scope: "participatory_process", block: "small", sort: true).in_groups_of(3).map do |metrics_group|
            content_tag :div, class: "row" do
              safe_join(
                metrics_group.map do |metric_manifest|
                  next "" if metric_manifest.blank?

                  render_metrics_data(metric_manifest.metric_name,
                                      klass: "column medium-4",
                                      ratio: "16:9",
                                      margin: "margin-top: 30px",
                                      graph_klass: "small",
                                      download: true,
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
