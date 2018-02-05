# frozen_string_literal: true

module Decidim
  module ContentParsers
    # A parser that searches mentions of Proposals in content.
    #
    # TODO:
    # TBD: A word starting with `@` will be considered as a possible mention if
    # they only contains letters, numbers or underscores. If the `@` is
    # followed with an underscore, then it is not considered.
    #
    # @see BaseParser Examples of how to use a content parser
    class ProposalParser < BaseParser
      # Class used as a container for metadata
      #
      # @!attribute proposals
      #   @return [Array] an array of Decidim::Proposals::Proposal mentioned in content
      Metadata = Struct.new(:proposals)

      # Matches a URL
      URL_REGEX = /(?i)\b((?:[a-z][\w-]+:(?:\/{1,3}|[a-z0-9%])|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}\/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’]))/i

      def initialize(content)
        super
        @metadata= Metadata.new([])
      end

      # Replaces found mentions matching a nickname of an existing
      # user with a global id. Other mentions found that doesn't
      # match an existing user are returned as is.
      #
      # @return [String] the content with the valid mentions replaced by a global id
      def rewrite
        content.gsub(URL_REGEX) do |match|
          proposal = proposal_from_match(match)
          if proposal
            @metadata.proposals << proposal
            proposal.to_global_id
          else
            match
          end
        end
      end

      # (see BaseParser#metadata)
      def metadata
        @metadata
      end

      def proposal_from_match(match)
        uri = URI.parse(match)
        proposal_id = uri.path.split("/").last
        Decidim::Proposals::Proposal.find_by_id(proposal_id) if proposal_id.present?
      end
    end
  end
end
