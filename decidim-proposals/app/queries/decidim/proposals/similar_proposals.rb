# frozen_string_literal: true

module Decidim
  module Proposals
    # Class used to retrieve similar proposals.
    class SimilarProposals < Rectify::Query
      include Decidim::TranslationsHelper

      # Syntactic sugar to initialize the class and return the queried objects.
      #
      # components - Decidim::CurrentComponent
      # proposal - Decidim::Proposals::Proposal
      def self.for(components, proposal)
        new(components, proposal).query
      end

      # Initializes the class.
      #
      # components - Decidim::CurrentComponent
      # proposal - Decidim::Proposals::Proposal
      def initialize(components, proposal)
        @components = components
        @proposal = proposal
      end

      # Retrieves similar proposals
      def query
        Decidim::Proposals::Proposal
          .where(component: @components)
          .published
          .where(
            "GREATEST(#{title_similarity}, #{body_similarity}) >= ?",
            @proposal.title,
            @proposal.body,
            Decidim::Proposals.similarity_threshold
          )
          .limit(Decidim::Proposals.similarity_limit)
      end

      private

      def title_similarity
        "similarity(title, ?)"
      end

      def body_similarity
        "similarity(body, ?)"
      end
    end
  end
end
