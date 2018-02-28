# frozen_string_literal: true

module Decidim
  module ContentParsers
    # A parser that searches mentions of Proposals in content.
    #
    # TODO:
    # A word starting with `~` will be considered as a possible mentioned proposal
    # if it only numbers.
    #
    # @see BaseParser Examples of how to use a content parser
    class ProposalParser < BaseParser
      # Class used as a container for metadata
      #
      # @!attribute proposals
      #   @return [Array] an array of Decidim::Proposals::Proposal mentioned in content
      Metadata = Struct.new(:proposals)

      # Matches a URL
      URL_REGEX = %r{/(?i)\b((?:[a-z][\w-]+:(?:\/{1,3}|[a-z0-9%])|www\d{0,3}[.]|[a-z0-9.\-]+
      [.][a-z]{2,4}\/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’]))/i}
      # Matches a mentioned Proposal ID (~(d)+ expression)
      ID_REGEX = /~(\d+)/

      def initialize(content, context)
        super
        @metadata = Metadata.new([])
      end

      # Replaces found mentions matching a nickname of an existing
      # user with a global id. Other mentions found that doesn't
      # match an existing user are returned as is.
      #
      # @return [String] the content with the valid mentions replaced by a global id
      def rewrite
        rewrited_content = parse_for_urls(content)
        parse_for_ids(rewrited_content)
      end

      # (see BaseParser#metadata)
      attr_reader :metadata

      #-------------------------------------------------

      private

      #-------------------------------------------------

      def parse_for_urls(content)
        content.gsub(URL_REGEX) do |match|
          proposal = proposal_from_url_match(match)
          if proposal
            @metadata.proposals << proposal
            proposal.to_global_id
          else
            match
          end
        end
      end

      def parse_for_ids(content)
        content.gsub(ID_REGEX) do |match|
          proposal = proposal_from_id_match(Regexp.last_match(1))
          if proposal
            @metadata.proposals << proposal
            proposal.to_global_id
          else
            match
          end
        end
      end

      def proposal_from_url_match(match)
        uri = URI.parse(match)
        proposal_id = uri.path.split("/").last
        find_proposal_by_id(proposal_id)
      end

      def proposal_from_id_match(match)
        proposal_id = match
        find_proposal_by_id(proposal_id)
      end

      def find_proposal_by_id(id)
        Decidim::Proposals::Proposal.find_by(id: id) if id.present?
      end
    end
  end
end
