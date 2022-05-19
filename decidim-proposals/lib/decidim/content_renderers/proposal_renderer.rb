# frozen_string_literal: true

module Decidim
  module ContentRenderers
    # A renderer that searches Global IDs representing proposals in content
    # and replaces it with a link to their show page.
    #
    # e.g. gid://<APP_NAME>/Decidim::Proposals::Proposal/1
    #
    # @see BaseRenderer Examples of how to use a content renderer
    class ProposalRenderer < BaseRenderer
      # Matches a global id representing a Decidim::User
      GLOBAL_ID_REGEX = %r{gid://([\w-]*/Decidim::Proposals::Proposal/(\d+))}i

      # Replaces found Global IDs matching an existing proposal with
      # a link to its show page. The Global IDs representing an
      # invalid Decidim::Proposals::Proposal are replaced with '???' string.
      #
      # @return [String] the content ready to display (contains HTML)
      def render(_options = nil)
        return content unless content.respond_to?(:gsub)

        content.gsub(GLOBAL_ID_REGEX) do |proposal_gid|
          proposal = GlobalID::Locator.locate(proposal_gid)
          Decidim::Proposals::ProposalPresenter.new(proposal).display_mention
        rescue ActiveRecord::RecordNotFound
          proposal_id = proposal_gid.split("/").last
          "~#{proposal_id}"
        end
      end
    end
  end
end
