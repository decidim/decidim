# frozen_string_literal: true

module Decidim
  # A presenter to render statistics in the homepage.
  class ParticipatoryProcessStatsPresenter < Rectify::Presenter
    attribute :participatory_process, Decidim::ParticipatoryProcess

    # Public: Render a collection of primary stats.
    def highlighted
      highlighted_stats = Decidim.stats.only([:comments_count]).with_context(published_features).map { |name, data| [:global, name, data] }
      highlighted_stats = highlighted_stats.concat(feature_stats)
      highlighted_stats = highlighted_stats.reject(&:empty?)

      safe_join(
        highlighted_stats.in_groups_of(2, false).map do |stats|
          content_tag :div, class: "home-pam__highlight" do
            safe_join(
              stats.map do |scope, name, data|
                render_stats_data(scope, name, data)
              end
            )
          end
        end
      )
    end

    private

    def which_stats
      {
        :proposals => [:proposals_count],
        :meetings => [:meetings_count],
        :budgets => [:projects_count, :orders_count],
        :pages => [:pages_count],
        :surveys => [:surveys_count, :answers_count]
      }
    end

    def feature_stats
      Decidim.feature_manifests.to_a.select { |feature| which_stats.keys.include? feature.name }.map do |feature|
        feature.stats
          .only(which_stats[feature.name])
          .with_context(published_features)
          .map { |name, data| [feature.name, name, data] }
      end.flatten(1)
    end

    def render_stats_data(scope, name, data)
      content_tag :div, "", class: "home-pam__data" do
        safe_join([
                    content_tag(:h4, I18n.t("#{scope}.#{name}", scope: "decidim.participatory_processes.statistics"), class: "home-pam__title"),
                    content_tag(:span, " #{number_with_delimiter(data)}", class: "home-pam__number #{scope} #{name}")
                  ])
      end
    end

    def published_features
      @published_features ||= Feature.where(participatory_process: participatory_process)
    end
  end
end
