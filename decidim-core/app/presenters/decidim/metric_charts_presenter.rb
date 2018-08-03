# frozen_string_literal: true

module Decidim
  # A presenter to render metrics in pages
  class MetricChartsPresenter < Rectify::Presenter
    attribute :organization, Decidim::Organization

    # Public: Render a collection of primary metrics.
    def highlighted
      highlighted_metrics = Decidim::MetricEntity.metric_entities & %w(usersMetric proposalsMetric)
      safe_join(
        highlighted_metrics.map do |metric|
          render_metrics_data(metric)
        end
      )
    end

    # Public: Render a collection of metrics that are not primary.
    def not_highlighted
      not_highlighted_metrics = Decidim::MetricEntity.metric_entities - %w(usersMetric proposalsMetric)
      safe_join(
        not_highlighted_metrics.map do |metric|
          render_metrics_data(metric, klass: "small")
        end
      )
    end

    private

    def render_metrics_data(metric, opts = {})
      content_tag :div, "", id: "#{metric.underscore}_chart", class: "areachart metric-chart #{opts[:klass]}",
                            data: { chart: "areachart", metric: metric,
                                    info: { title: I18n.t("decidim.metrics.#{metric.underscore}.title"),
                                            object: I18n.t("decidim.metrics.#{metric.underscore}.object") } }
    end
  end
end
