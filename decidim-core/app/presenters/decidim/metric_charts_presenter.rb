# frozen_string_literal: true

module Decidim
  # A presenter to render metrics in pages
  class MetricChartsPresenter < Rectify::Presenter
    attribute :organization, Decidim::Organization

    # Public: Render a collection of primary metrics.
    def highlighted
      highlighted_metrics = Decidim.metrics_registry.highlighted
      safe_join(
        highlighted_metrics.map do |metric|
          render_metrics_data(metric.metric_name, klass: "column medium-4")
        end
      )
    end

    # Public: Render a collection of metrics that are not primary.
    def not_highlighted
      not_highlighted_metrics = Decidim.metrics_registry.not_highlighted
      safe_join(
        not_highlighted_metrics.in_groups_of(2, [:empty]).map do |metrics_group|
          content_tag :div, class: "column medium-4" do
            safe_join(
              metrics_group.map do |metric|
                render_metrics_data(metric.metric_name, klass: "column medium-6", graph_klass: "small")
              end
            )
          end
        end
      )
    end

    private

    def render_metrics_data(metric_name, opts = {})
      content_tag :div, class: opts[:klass].presence || "column medium-6" do
        content_tag :div, "", id: "#{metric_name}_chart", class: "areachart metric-chart #{opts[:graph_klass]}",
                              data: { chart: "areachart", metric: metric_name,
                                      info: { title: I18n.t("decidim.metrics.#{metric_name}.title"),
                                              object: I18n.t("decidim.metrics.#{metric_name}.object") } }
      end
    end
  end
end
