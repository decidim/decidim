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
          content_tag :div, class: "column medium-4" do
            render_metrics_data(metric)
          end
        end
      )
    end

    # Public: Render a collection of metrics that are not primary.
    def not_highlighted
      not_highlighted_metrics = Decidim::MetricEntity.metric_entities - %w(usersMetric proposalsMetric)

      safe_join(
        not_highlighted_metrics.map do |metric|
          content_tag :div, class: "column medium-4 left" do
            content_tag :div, class: "column medium-6" do
              render_metrics_data(metric, klass: "small")
            end
          end
        end
      )
    end

    private

    def render_metrics_data(metric, opts = {})
      content_tag :div, "", id: "#{metric}_chart", class: "areachart metric-chart #{opts[:klass]}",
                            data: { chart: "areachart", metric: metric,
                                    info: { title: I18n.t("decidim.metrics.#{metric}.title"),
                                            object: I18n.t("decidim.metrics.#{metric}.object") } }
    end
  end
end
