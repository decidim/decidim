# frozen_string_literal: true

module Decidim
  module Debates
    module Log
      class ResourcePresenter < Decidim::Log::ResourcePresenter
        private

        # Private: Presents resource name.
        #
        # Returns an HTML-safe String.
        def present_resource_name
          Decidim::Debates::DebatePresenter.new(resource).title
        end
      end
    end
  end
end
