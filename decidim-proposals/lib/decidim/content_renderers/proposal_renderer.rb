# frozen_string_literal: true

module Decidim
  module ContentRenderers
    # A renderer that searches Global IDs representing proposals in content
    # and replaces it with a link to their show page.
    #
    # e.g. gid://<APP_NAME>/Decidim::Proposals::Proposal/1
    #
    # @see BaseRenderer Examples of how to use a content renderer
    class ProposalRenderer < ResourceRenderer
      def regex
        %r{gid://([\w-]*/Decidim::Proposals::Proposal/(\d+))}i
      end
    end
  end
end
