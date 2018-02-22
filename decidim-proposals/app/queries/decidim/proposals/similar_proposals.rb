# frozen_string_literal: true

module Decidim
  module Proposals
    # Class used to retrieve similar proposals.
    class SimilarProposals < Rectify::Query
      include Decidim::TranslationsHelper

      # Syntactic sugar to initialize the class and return the queried objects.
      #
      # features - Decidim::CurrentFeature
      # proposal - Decidim::Proposals::Proposal
      def self.for(features, proposal)
        new(features, proposal).query
      end

      # Initializes the class.
      #
      # features - Decidim::CurrentFeature
      # proposal - Decidim::Proposals::Proposal
      def initialize(features, proposal)
        @features = features
        @proposal = proposal
      end

      # Retrieves similar proposals
      def query
        Decidim::Proposals::Proposal
          .where(feature: @features)
          .published
          .where(
            "GREATEST(#{title_similarity}, #{body_similarity}) >= ?",
            proposal.title,
            proposal.body,
            Decidim::Proposals.similarity_threshold
          )
          .limit(Decidim::Proposals.similarity_limit)
      end

      private

      attr_reader :proposal

      def title_similarity
        "similarity(title, ?)"
      end

      def body_similarity
        "similarity(body, ?)"
      end
    end
  end
end
