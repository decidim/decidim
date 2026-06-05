# frozen_string_literal: true

module Decidim
  module AdminLog
    # This class extends the default resource presenter for logs, so that
    # it can properly link to the static page.
    class StaticPageResourcePresenter < Decidim::Log::ResourcePresenter
      private

      # Private: Finds the public link for the given static page..
      #
      # Returns an HTML-safe String.
      def resource_path
        @resource_path ||= h.decidim.page_path(resource, locale: I18n.locale)
      end
    end
  end
end
