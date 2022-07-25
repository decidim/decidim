# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class StatsCell < Decidim::ViewModel
      def stats
        @stats ||= HomeStatsPresenter.new(organization: current_organization)
      end

      private

      def cache_hash
        hash = []
        hash.push(I18n.locale)
        hash.push(current_organization.cache_key)
        hash.join(Decidim.cache_key_separator)
      end

      def cache_expiry_time
        10.minutes
      end
    end
  end
end
