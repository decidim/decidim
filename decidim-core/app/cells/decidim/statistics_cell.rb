# frozen_string_literal: true

module Decidim
  # This cell renders the Statistics of a Resource
  class StatisticsCell < Decidim::ViewModel
    private

    def stats
      @stats ||= model
    end

    def no_stats
      t("decidim.statistics.no_stats")
    end

    # REDESING_PENDING: deprecated
    def stats_heading
      t("decidim.statistics.headline")
    end

    # REDESING_PENDING: deprecated
    def heading?
      if options[:heading].nil?
        true
      else
        options[:heading]
      end
    end

    # REDESING_PENDING: deprecated
    def design
      options[:design].presence || "default"
    end

    # REDESING_PENDING: deprecated
    def wrapper_class
      "large-8" if design == "default"
    end
  end
end
