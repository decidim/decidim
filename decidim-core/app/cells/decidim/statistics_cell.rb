# frozen_string_literal: true

module Decidim
  # This cell renders the Statistics of a Resource
  class StatisticsCell < Decidim::ViewModel
    private

    def stats
      @stats ||= model
    end

    def stats_heading
      t("decidim.statistics.headline")
    end

    def no_stats
      t("decidim.statistics.no_stats")
    end

    def heading?
      if options[:heading].nil?
        true
      else
        options[:heading]
      end
    end

    def design
      options[:design].presence || "default"
    end

    def wrapper_class
      "large-8" if design == "default"
    end
  end
end
