# frozen_string_literal: true

module Decidim
  # A presenter to render metrics in pages
  class MetricChartsPresenter < SimpleDelegator
    delegate :content_tag, :concat, :safe_join, to: :view_context

    def view_context
      @view_context ||= __getobj__.fetch(:view_context, ActionController::Base.new.view_context)
    end

    # Public: Render a collection of primary metrics.
    def highlighted
      render_highlighted(highlighted_metrics)
    end

    # Public: Render a collection of metrics that are not primary.
    def not_highlighted
      render_not_highlighted(not_highlighted_metrics)
    end

    def highlighted_metrics
      Decidim.metrics_registry.filtered(highlight: true, scope: "home")
    end

    def not_highlighted_metrics
      Decidim.metrics_registry.filtered(highlight: false, scope: "home")
    end

    private

    def highlighted_classes
      "column medium-4"
    end

    def not_highlighted_classes
      "column medium-6"
    end

    def not_highlighted_wrapper_classes
      "column medium-4"
    end

    def render_highlighted(metrics)
      safe_join(
        metrics.map do |metric|
          render_metrics_data(metric.metric_name, klass: highlighted_classes)
        end
      )
    end

    def render_not_highlighted(metrics)
      safe_join(
        metrics.in_groups_of(2).map do |metrics_group|
          content_tag :div, class: not_highlighted_wrapper_classes do
            safe_join(
              metrics_group.map do |metric|
                next "" if metric.blank?

                render_metrics_data(metric.metric_name, klass: not_highlighted_classes, graph_klass: "small")
              end
            )
          end
        end
      )
    end

    def render_metrics_data(metric_name, opts = {})
      content_tag :div, class: opts[:klass].presence || not_highlighted_classes do
        concat render_metric_chart(metric_name, opts)
        concat render_downloader(metric_name) if opts[:download]
      end
    end

    def render_metrics_descriptive(metric_name, opts = {})
      content_tag :div, class: opts[:klass].presence || not_highlighted_classes do
        concat content_tag(:h3, opts[:title], class: "metric-title heading3 text-muted")
        concat content_tag(:p, opts[:description], class: "metric-description text-medium")
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
      content_tag :p, class: "pull-right mt-s" do
        link_to "#", class: "metric-downloader", data: { metric: metric_name } do
          content_tag :small, class: "text-small" do
            content_tag :span, I18n.t("decidim.metrics.download.csv")
          end
        end
      end
    end
  end
end
