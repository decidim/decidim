# frozen_string_literal: true

module Decidim
  module Log
    class UserResourcePresenter < Decidim::Log::ResourcePresenter
      private

      # Private: Presents user name, even if it's blocked.
      #
      # Returns an HTML-safe String.
      def present_resource_name
        h.translated_attribute resource.try(:user_name).presence || extra["title"]
      end
    end
  end
end
