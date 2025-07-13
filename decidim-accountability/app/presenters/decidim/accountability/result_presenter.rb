# frozen_string_literal: true

module Decidim
  module Accountability
    #
    # Decorator for results
    #
    class ResultPresenter < Decidim::ResourcePresenter
      include Rails.application.routes.mounted_helpers
      include ActionView::Helpers::UrlHelper
      include Decidim::SanitizeHelper

      def result
        __getobj__
      end

      # Render the result title
      #
      # Returns a String.
      def title(links: false, extras: true, html_escape: false, all_locales: false)
        return unless result

        super(result.title, links, html_escape, all_locales, extras:)
      end
    end
  end
end
