# frozen_string_literal: true

module Decidim
  # A presenter to render metrics in pages
  class MetricChartsPresenter < SimpleDelegator
    delegate :content_tag, :concat, :safe_join, :link_to, to: :view_context

    def view_context
      @view_context ||= __getobj__.fetch(:view_context, ActionController::Base.new.view_context)
    end

    # Public: Render a collection of primary metrics.
    def highlighted
      render_metrics(highlighted_metrics)
    end

    # Public: Render a collection of metrics that are not primary.
    def not_highlighted
      render_metrics(not_highlighted_metrics)
    end

    def highlighted_metrics
      Decidim.metrics_registry.filtered(highlight: true, scope: "home")
    end

    def not_highlighted_metrics
      Decidim.metrics_registry.filtered(highlight: false, scope: "home")
    end

    def render_charts(charts)
      safe_join(
        charts.map do |metric_manifest|
          render_metric(metric_manifest.metric_name,
                        title: I18n.t("decidim.metrics.#{metric_manifest.metric_name}.title"),
                        description: I18n.t("decidim.metrics.#{metric_manifest.metric_name}.description"),
                        download: true,
                        data: { ratio: "11:4", axis: true }).html_safe
        end
      )
    end

    def render_metrics(metrics)
      safe_join(
        metrics.map do |metric|
          render_metric(metric.metric_name, klass: metrics_class)
        end
      )
    end

    private

    def metrics_class
      "column medium-4"
    end

    def render_metric(metric_name, opts = {})
      content_tag :div, class: "metric" do
        concat content_tag(:h3, opts[:title]) if opts[:title]
        concat content_tag(:p, opts[:description]) if opts[:description]
        concat render_metric_chart(metric_name, opts)
        concat render_downloader(metric_name) if opts[:download]
      end
    end

    def render_metric_chart(metric_name, opts = {})
      data = {
        chart: "areachart",
        metric: metric_name,
        info: {
          title: I18n.t("decidim.metrics.#{metric_name}.title"),
          object: I18n.t("decidim.metrics.#{metric_name}.object")
        }
      }
      data.merge!(opts[:data] || {})

      content_tag :div,
                  "",
                  id: "#{metric_name}_chart",
                  class: "areachart metric-chart #{opts[:graph_klass]}",
                  style: opts[:margin],
                  data:
    end

    def render_downloader(metric_name)
      link_to "#", class: "metric-downloader", data: { metric: metric_name } do
        content_tag :small do
          content_tag :span, I18n.t("decidim.metrics.download.csv")
        end
      end
    end
  end
end
