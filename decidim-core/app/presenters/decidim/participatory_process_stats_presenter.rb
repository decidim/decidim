# frozen_string_literal: true

module Decidim
  # A presenter to render statistics in the homepage.
  class ParticipatoryProcessStatsPresenter < Rectify::Presenter
    attribute :participatory_process, Decidim::ParticipatoryProcess

    # Public: Render a collection of primary stats.
    def highlighted
      highlighted_stats = Decidim.stats.only([:comments_count]).with_context(published_features).map { |name, data| [:global, name, data] }
      highlighted_stats = highlighted_stats.concat(feature_stats(feature_stats_list))
      highlighted_stats = highlighted_stats.reject(&:empty?)

      safe_join(
        highlighted_stats.in_groups_of(4, false).map do |stats|
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

    def not_highlighted
      not_highlighted_stats = feature_stats(stats_list)
      not_highlighted_stats = not_highlighted_stats.reject(&:empty?)

      safe_join(
        not_highlighted_stats.in_groups_of(4, false).map do |stats|
          content_tag :div, class: "home-pam__lowlight" do
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

    def feature_stats_list
      {
        :proposals => [:proposals_count],
        :meetings => [:meetings_count],
        :budgets => [:projects_count, :orders_count],
        :pages => [:pages_count],
        :surveys => [:surveys_count, :answers_count]
      }
    end

    def stats_list
      {
        :proposals => [:comments_count],
        :meetings => [:comments_count],
        :pages => [:comments_count],
        :results => [:comments_count]
      }
    end

    def feature_stats(list)
      Decidim.feature_manifests.to_a.select { |feature| list.keys.include? feature.name }.map do |feature|
        feature.stats
          .only(list[feature.name])
          .with_context(published_features)
          .map { |name, data| [feature.name, name, data] }
      end.flatten(1)
    end

    def render_stats_data(scope, name, data)
      content_tag :div, "", class: "home-pam__data" do
        safe_join([
                    content_tag(:h4, I18n.t("#{scope}.#{name}", scope: "decidim.participatory_processes.statistics"), class: "text-center home-pam__title"),
                    content_tag(:span, " #{number_with_delimiter(data)} ", class: "#{scope} #{name} home-pam__number")
                  ])
      end
    end

    def published_features
      @published_features ||= Feature.where(participatory_process: participatory_process)
    end
  end
end
