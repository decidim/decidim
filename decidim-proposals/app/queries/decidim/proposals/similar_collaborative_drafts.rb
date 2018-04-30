# frozen_string_literal: true

module Decidim
  module Proposals
    # Class used to retrieve similar collaborative_drafts.
    class SimilarCollaborativeDrafts < Rectify::Query
      include Decidim::TranslationsHelper

      # Syntactic sugar to initialize the class and return the queried objects.
      #
      # component - Decidim::CurrentComponent
      # collaborative_draft - Decidim::Proposals::CollaborativeDraft
      def self.for(component, collaborative_draft)
        new(component, collaborative_draft).query
      end

      # Initializes the class.
      #
      # component - Decidim::CurrentComponent
      # collaborative_draft - Decidim::Proposals::CollaborativeDraft
      def initialize(component, collaborative_draft)
        @component = component
        @collaborative_draft = collaborative_draft
      end

      # Retrieves similar collaborative_drafts
      def query
        Decidim::Proposals::CollaborativeDraft
          .where(component: @component)
          .where(
            "GREATEST(#{title_similarity}, #{body_similarity}) >= ?",
            @collaborative_draft[:title],
            @collaborative_draft[:body],
            Decidim::Proposals.similarity_threshold
          )
          .limit(Decidim::Proposals.similarity_limit)
      end

      private

      attr_reader :collaborative_draft

      def title_similarity
        "similarity(title, ?)"
      end

      def body_similarity
        "similarity(body, ?)"
      end
    end
  end
end
