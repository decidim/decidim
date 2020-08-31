# frozen_string_literal: true

module Decidim
  # A Helper to find and render the author of a version.
  module TraceabilityHelper
    include Decidim::SanitizeHelper
    # Renders the avatar and author name of the author of the last version of the given
    # resource.
    #
    # resource - an object implementing `Decidim::Traceable`
    #
    # Returns an HTML-safe String representing the HTML to render the author.
    def render_resource_last_editor(resource)
      cell "decidim/version_author", Decidim.traceability.last_editor(resource)
    end

    # Renders the avatar and author name of the author of the given version.
    #
    # version - an object that responds to `whodunnit` and returns a String.
    #
    # Returns an HTML-safe String representing the HTML to render the author.
    def render_resource_editor(version)
      cell "decidim/version_author", Decidim.traceability.version_editor(version)
    end
  end
end
