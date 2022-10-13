# frozen_string_literal: true

module Decidim
  # A Helper to find and render the author of a version.
  module TraceabilityHelper
    include Decidim::SanitizeHelper
    include Decidim::ApplicationHelper

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
      # REDESIGN_PENDING: Allow to pass the date as an input variable.
      # Currently the "context_actions: [:date]"-param autocalculates the value dispayed.
      # Once done, pass "current_version.created_at" to the cell
      cell "decidim/author", present(Decidim.traceability.version_editor(version)), context_actions: [:date], layout: :compact
    end
  end
end
