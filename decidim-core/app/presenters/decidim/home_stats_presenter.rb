# frozen_string_literal: true

module Decidim
  # A presenter to render statistics in the homepage.
  class HomeStatsPresenter < StatsPresenter
    def scope_entity
      __getobj__.fetch(:organization)
    end

    def collection(priority: StatsRegistry::HIGH_PRIORITY)
      super
    end
  end
end
