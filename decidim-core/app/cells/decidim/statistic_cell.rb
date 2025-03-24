# frozen_string_literal: true

module Decidim
  # This cell renders a Statistic of a Resource
  class StatisticCell < Decidim::ViewModel
    private

    def stat_number
      number_with_delimiter(model[:stat_number])
    end

    def stat_dom_class
      model[:stat_title]
    end

    def stat_title
      t(model[:stat_title], scope: "decidim.statistics")
    end

    def information_tooltip
      tooltip_key = "#{model[:stat_title]}_tooltip"
      with_tooltip(t(tooltip_key, scope: "decidim.statistics", default: "")) do
        icon("information-line")
      end
    end

    def stat_icon
      icon_map = {
        users_count: "user-line",
        processes_count: "treasure-map-line",
        assemblies_count: "government-line",
        initiatives_count: "lightbulb-flash-line",
        conferences_count: "user-voice-line",
        proposals_count: "chat-new-line",
        meetings_count: "map-pin-line",
        comments_count: "chat-1-line",
        followers_count: "user-follow-line",
        debates_count: "discuss-line",
        results_count: "briefcase-2-line",
        projects_count: "git-pull-request-line",
        posts_count: "pen-nib-line",
        surveys_count: "survey-line",
        sortitions_count: "team-line"
      }

      icon(icon_map[model[:stat_title].to_sym] || "")
    end
  end
end
