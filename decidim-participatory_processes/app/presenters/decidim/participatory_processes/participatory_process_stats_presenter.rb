# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # A presenter to render statistics in the homepage.
    class ParticipatoryProcessStatsPresenter < Rectify::Presenter
      attribute :participatory_process, Decidim::ParticipatoryProcess
      include Decidim::IconHelper

      # Public: Render a collection of primary stats.
      def highlighted
        highlighted_stats = process_stats(priority: StatsRegistry::HIGH_PRIORITY)
        highlighted_stats = highlighted_stats.concat(component_stats(priority: StatsRegistry::HIGH_PRIORITY))
        highlighted_stats = highlighted_stats.concat(component_stats(priority: StatsRegistry::MEDIUM_PRIORITY))
        highlighted_stats = highlighted_stats.reject(&:empty?)
        highlighted_stats = highlighted_stats.reject { |_manifest, _name, data| data.zero? }
        grouped_highlighted_stats = highlighted_stats.group_by { |stats| stats.first.name }

        safe_join(
          grouped_highlighted_stats.map do |_manifest_name, stats|
            content_tag :div, class: "process_stats-item" do
              safe_join(
                stats.each_with_index.map do |stat, index|
                  stat.each_with_index.map do |_item, subindex|
                    render_stats_data(stat[subindex], stat[subindex + 1], stat[subindex + 2], (index + subindex)) if (subindex % 3).zero?
                  end
                end
              )
            end
          end
        )
      end

      private

      def component_stats(conditions)
        Decidim.component_manifests.map do |component_manifest|
          component_manifest.stats.except([:proposals_accepted])
                            .filter(conditions)
                            .with_context(published_components)
                            .map { |name, data| [component_manifest, name, data] }.flatten
        end
      end

      def process_stats(conditions)
        Decidim.stats.only([:followers_count])
               .filter(conditions)
               .with_context(participatory_process)
               .map { |name, data| [participatory_process.manifest, name, data] }
      end

      def render_stats_data(component_manifest, name, data, index)
        safe_join([
                    index.zero? ? manifest_icon(component_manifest) : " /&nbsp".html_safe,
                    content_tag(:span, "#{number_with_delimiter(data)} " + I18n.t(name, scope: "decidim.participatory_processes.statistics"),
                                class: "#{name} process_stats-text")
                  ])
      end

      def published_components
        @published_components ||= Component.where(participatory_space: participatory_process).published
      end
    end
  end
end
