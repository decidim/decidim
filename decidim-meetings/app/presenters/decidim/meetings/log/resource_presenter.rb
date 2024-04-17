# frozen_string_literal: true

module Decidim
  module Meetings
    module Log
      class ResourcePresenter < Decidim::Log::ResourcePresenter
        private

        # Private: Presents resource name.
        #
        # Returns an HTML-safe String.
        def present_resource_name
          if resource.present?
            resource.presenter.title(html_escape: true)
          else
            super
          end
        end
      end
    end
  end
end
