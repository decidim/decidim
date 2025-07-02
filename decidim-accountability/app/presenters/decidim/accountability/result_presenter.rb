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
      def title(links: nil, extras: nil, html_escape: false, all_locales: false)
        return unless result

        raise "Extras have been set" unless extras.nil?
        raise "Links have been set" unless links.nil?

        super(result.title, html_escape, all_locales)
      end
    end
  end
end
