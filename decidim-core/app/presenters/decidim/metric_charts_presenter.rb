# frozen_string_literal: true

module Decidim
  # A presenter to render metrics in pages
  class MetricChartsPresenter < Rectify::Presenter
    # Public: Render a collection of primary metrics.
    def highlighted
      render_highlighted(Decidim.metrics_registry.highlighted)
    end

    # Public: Render a collection of metrics that are not primary.
    def not_highlighted
      render_not_highlighted(Decidim.metrics_registry.not_highlighted)
    end

    private

    def render_highlighted(highlighted_metrics)
      safe_join(
        highlighted_metrics.map do |metric|
          render_metrics_data(metric.metric_name, klass: "column medium-4")
        end
      )
    end

    def render_not_highlighted(not_highlighted_metrics)
      safe_join(
        not_highlighted_metrics.in_groups_of(2).map do |metrics_group|
          content_tag :div, class: "column medium-4" do
            safe_join(
              metrics_group.map do |metric|
                next "" if metric.blank?
                render_metrics_data(metric.metric_name, klass: "column medium-6", graph_klass: "small")
              end
            )
          end
        end
      )
    end

    def render_metrics_data(metric_name, opts = {})
      content_tag :div, class: opts[:klass].presence || "column medium-6" do
        concat content_tag(:h3, opts[:title], class: "heading3 text-uppercase text-muted")
        concat content_tag(:p, opts[:description], class: "text-medium")
        render_metric_chart(metric_name, opts)
      end
    end

    def render_metric_chart(metric_name, opts = {})
      concat content_tag :div,
                         "",
                         id: "#{metric_name}_chart",
                         class: "areachart metric-chart #{opts[:graph_klass]}",
                         style: opts[:margin],
                         data: {
                           chart: "areachart",
                           metric: metric_name,
                           ratio: (opts[:ratio]).to_s,
                           axis: opts[:axis],
                           tip: true,
                           info: {
                             title: I18n.t("decidim.metrics.#{metric_name}.title")
                           }
                         }
    end
  end
end
