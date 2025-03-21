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
  end
end
