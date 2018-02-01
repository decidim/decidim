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
      GLOBAL_ID_REGEX = %r{gid://.*/Decidim::Proposals::Proposal/\d+}

      # Replaces found Global IDs matching an existing proposal with
      # a link to their profile. The Global IDs representing an
      # invalid Decidim::Proposals::Proposal are replaced with '???' string.
      #
      # @return [String] the content ready to display (contains HTML)
      def render
=begin
        content.gsub(GLOBAL_ID_REGEX) do |user_gid|
          begin
            user = GlobalID::Locator.locate(user_gid)
            Decidim::UserPresenter.new(user).display_mention
          rescue ActiveRecord::RecordNotFound => _ex
            ""
          end
        end
=end
        content
      end
    end
  end
end
