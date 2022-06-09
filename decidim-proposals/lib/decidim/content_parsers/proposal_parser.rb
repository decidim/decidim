# frozen_string_literal: true

module Decidim
  module ContentParsers
    # A parser that searches mentions of Proposals in content.
    #
    # This parser accepts two ways for linking Proposals.
    # - Using a standard url starting with http or https.
    # - With a word starting with `~` and digits afterwards will be considered a possible mentioned proposal.
    # For example `~1234`, but no `~ 1234`.
    #
    # Also fills a `Metadata#linked_proposals` attribute.
    #
    # @see BaseParser Examples of how to use a content parser
    class ProposalParser < ResourceParser
      # Class used as a container for metadata
      #
      # @!attribute linked_proposals
      #   @return [Array] an array of Decidim::Proposals::Proposal mentioned in content
      Metadata = Struct.new(:linked_proposals)

      def initialize(content, context)
        super
        @metadata = Metadata.new([])
      end

      # (see BaseParser#metadata)
      attr_reader :metadata

      private

      def url_regex
        %r{#{URL_REGEX_SCHEME}#{URL_REGEX_CONTENT}/proposals/#{URL_REGEX_END_CHAR}+}i
      end

      def model_class
        "Decidim::Proposals::Proposal"
      end

      def update_metadata(resource)
        @metadata.linked_proposals << resource.id
      end
    end
  end
end
