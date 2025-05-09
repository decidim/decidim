# frozen_string_literal: true

module Decidim
  # This cell renders a Statistic of a Resource
  class StatisticCell < Decidim::ViewModel
    private

    def stat_number
      number_with_delimiter(model[:data][0])
    end

    def second_stat_number
      number_with_delimiter(model[:data][1]) if model[:data].size > 1
    end

    def stat_dom_class
      model[:name]
    end

    def stat_title
      t(model[:name], scope: "decidim.statistics")
    end

    def stat_sub_title
      return if model[:sub_title].blank?

      t(model[:sub_title], scope: "decidim.statistics")
    end

    def information_tooltip
      return if model[:tooltip_key].blank?

      tooltip_key = model[:tooltip_key].to_s
      with_tooltip(t(tooltip_key, scope: "decidim.statistics"), class: "top") do
        icon("information-line")
      end
    end

    def stat_icon
      return if model[:icon_name].blank?

      icon(model[:icon_name].to_sym)
    end
  end
end
