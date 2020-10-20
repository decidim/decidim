# frozen_string_literal: true

module Decidim
  module Conferences
    # A presenter to render statistics in the homepage.
    class ConferenceStatsPresenter < Rectify::Presenter
      attribute :conference, Decidim::Conference
      include IconHelper

      # Public: Render a collection of primary stats.
      def highlighted
        highlighted_stats = component_stats(priority: StatsRegistry::HIGH_PRIORITY)
        highlighted_stats.concat(component_stats(priority: StatsRegistry::MEDIUM_PRIORITY))
        highlighted_stats = highlighted_stats.reject(&:empty?)
        highlighted_stats = highlighted_stats.reject { |_manifest, _name, data| data.zero? }
        grouped_highlighted_stats = highlighted_stats.group_by { |stats| stats.first.name }

        safe_join(
          grouped_highlighted_stats.map do |_manifest_name, stats|
            content_tag :div, class: "process_stats-item" do
              safe_join(
                stats.each_with_index.map do |stat, index|
                  render_stats_data(stat[0], stat[1], stat[2], index)
                end
              )
            end
          end
        )
      end

      private

      def component_stats(conditions)
        Decidim.component_manifests.map do |component_manifest|
          component_manifest.stats.filter(conditions).with_context(published_components).map { |name, data| [component_manifest, name, data] }.flatten
        end
      end

      def render_stats_data(component_manifest, name, data, index)
        safe_join([
                    index.zero? ? manifest_icon(component_manifest, role: "img", "aria-hidden": true) : " /&nbsp".html_safe,
                    content_tag(:span, "#{number_with_delimiter(data)} " + I18n.t(name, scope: "decidim.conferences.statistics"),
                                class: "#{name} process_stats-text")
                  ])
      end

      def published_components
        @published_components ||= Component.where(participatory_space: conference).published
      end
    end
  end
end
