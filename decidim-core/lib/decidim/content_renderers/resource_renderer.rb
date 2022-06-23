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
        return content unless content.respond_to?(:gsub)

        content.gsub(regex) do |resource_gid|
          resource = GlobalID::Locator.locate(resource_gid)
          resource.presenter.display_mention
        rescue ActiveRecord::RecordNotFound
          resource_id = resource_gid.split("/").last
          "~#{resource_id}"
        end
      end

      def regex
        raise "Not implemented"
      end
    end
  end
end
