# frozen_string_literal: true

module Decidim
  module ContentRenderers
    # A renderer that searches Global IDs representing results in content
    # and replaces it with a link to their show page.
    #
    # e.g. gid://<APP_NAME>/Decidim::Accountability::Result/1
    #
    # @see BaseRenderer Examples of how to use a content renderer
    class ResultRenderer < BaseRenderer
      # Matches a global id representing a Decidim::User
      GLOBAL_ID_REGEX = %r{gid:\/\/([\w-]*\/Decidim::Accountability::Result\/(\d+))}i

      # Replaces found Global IDs matching an existing result with
      # a link to its show page. The Global IDs representing an
      # invalid Decidim::Accountability::Result are replaced with '???' string.
      #
      # @return [String] the content ready to display (contains HTML)
      def render
        content.gsub(GLOBAL_ID_REGEX) do |result_gid|
          begin
            result = GlobalID::Locator.locate(result_gid)
            Decidim::Accountability::ResultPresenter.new(result).display_mention
          rescue ActiveRecord::RecordNotFound
            result_id = result_gid.split("/").last
            "~#{result_id}"
          end
        end
      end
    end
  end
end
