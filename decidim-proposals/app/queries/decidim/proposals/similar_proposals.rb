# frozen_string_literal: true

module Decidim
  module Proposals
    # Class uses to retrieve similar proposals.
    class SimilarProposals < Rectify::Query
      include Decidim::TranslationsHelper

      # Syntactic sugar to initialize the class and return the queried objects.
      #
      # features - Decidim::CurrentFeature
      # form - Decidim::Proposals::ProposalWizardForm
      def self.for(features, form)
        new(features, form).query
      end

      # Initializes the class.
      #
      # features - Decidim::CurrentFeature
      # form - Decidim::Proposals::ProposalWizardForm
      def initialize(features, form)
        @features = features
        @form = form
      end

      # Retrieves similar proposals
      def query
        Decidim::Proposals::Proposal
          .where(feature: @features)
          .where(
            "GREATEST(#{title_similarity}, #{body_similarity}) >= ?",
            form.title,
            form.body,
            Decidim::Proposals.similarity_threshold
          )
          .limit(Decidim::Proposals.similarity_limit)
      end

      private

      attr_reader :form

      def title_similarity
        "similarity(title, ?)"
      end

      def body_similarity
        "similarity(body, ?)"
      end
    end
  end
end
