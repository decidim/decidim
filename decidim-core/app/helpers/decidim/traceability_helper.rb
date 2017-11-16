# frozen_string_literal: true

module Decidim
  # A Helper to find and render the author of a version.
  module TraceabilityHelper
    # Renders the avatar and author name of the author of the last version of the given
    # resource.
    #
    # resource - an object implementing `Decidim::Traceable`
    #
    # Returns an HTML-safe String representing the HTML to render the author.
    def render_resource_last_editor(resource)
      render partial: "decidim/shared/version_author",
             locals: {
               author: resource_last_editor(resource)
             }
    end

    # Finds the author of the last version of the resource.
    #
    # resource - an object implementing `Decidim::Traceable`
    #
    # Returns an object identifiable via GlobalID or a String.
    def resource_last_editor(resource)
      version_author(resource.versions.last)
    end

    # Finds the author of the given version.
    #
    # version - an object that responds to `whodunnit` and returns a String.
    #
    # Returns an object identifiable via GlobalID or a String.
    def version_author(version)
      ::GlobalID::Locator.locate(version.whodunnit) || version.whodunnit
    end
  end
end
