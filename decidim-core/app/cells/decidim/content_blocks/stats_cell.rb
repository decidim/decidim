# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class StatsCell < Decidim::ViewModel
      cache :show, expires_in: 10.minutes, if: :perform_caching? do
        cache_hash
      end

      def stats
        @stats ||= HomeStatsPresenter.new(organization: current_organization)
      end

      private

      def cache_hash
        hash = []
        hash.push(I18n.locale)
        hash.join(Decidim.cache_key_separator)
      end
    end
  end
end
