# frozen_string_literal: true

module Decidim
  module Votings
    #
    # Decorator for polling station
    #
    class PollingStationPresenter < SimpleDelegator
      include Decidim::SanitizeHelper
      include Decidim::TranslatableAttributes

      def polling_station
        __getobj__
      end

      def title
        content = translated_attribute(polling_station.title)
        decidim_html_escape(content)
      end

      def address
        content = translated_attribute(polling_station.address)
        decidim_html_escape(content)
      end
    end
  end
end
