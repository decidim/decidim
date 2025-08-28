# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    module AdminLog
      # This class extends the default resource presenter for logs, so that
      # it can properly link to the newsletter.
      class SuggestionResourcePresenter < Decidim::Log::ResourcePresenter
        private

        # Private: Finds the admin link for the newsletter.
        #
        # Returns an HTML-safe String.
        def resource_path
          @resource_path ||= Decidim::ResourceLocatorPresenter.new(resource.document).path(anchor: "ct-node-#{resource.changeset["firstNode"]}")
        end
      end
    end
  end
end
