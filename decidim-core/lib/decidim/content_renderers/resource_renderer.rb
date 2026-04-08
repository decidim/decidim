# frozen_string_literal: true

module Decidim
  module ContentRenderers
    class ResourceRenderer < BaseRenderer
      # Matches a global id representing a Decidim::User

      # Replaces found Global IDs matching an existing resource with
      # a link to its show page. The Global IDs representing an
      # invalid Resource are replaced with '???' string.
      #
      # @return [String] the content ready to display (contains HTML)
      def render(_options = nil)
        replace_pattern_by_context(content, regex, on_missing: proc { |match, _| "~#{match.split("/").last}" }) do |resource_gid, _context|
          resource = GlobalID::Locator.locate(resource_gid)
          resource.presenter.display_mention
        end
      end

      protected

      def regex
        raise "Not implemented"
      end
    end
  end
end
