# frozen_string_literal: true

module Decidim
  module Proposals
    # Class used to retrieve similar proposals.
    class SimilarProposals < Decidim::Query
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
        @translations_enabled = proposal.component.organization.enable_machine_translations
      end

      # Retrieves similar proposals
      def query
        Decidim::Proposals::Proposal
          .where(component: @components)
          .published
          .not_hidden
          .where(
            Arel.sql("GREATEST(#{title_similarity}, #{body_similarity}) >= ?").to_s,
            *similarity_params,
            Decidim::Proposals.similarity_threshold
          )
          .limit(Decidim::Proposals.similarity_limit)
      end

      private

      attr_reader :translations_enabled, :proposal

      def title_similarity
        return "similarity(title::text, ?)" unless translations_enabled

        language = proposal.content_original_language
        "similarity(title->>'#{language}'::text, ?), similarity(title->'machine_translations'->>'#{language}'::text, ?)"
      end

      def body_similarity
        return "similarity(body::text, ?)" unless translations_enabled

        language = proposal.content_original_language
        "similarity(body->>'#{language}'::text, ?), similarity(body->'machine_translations'->>'#{language}'::text, ?)"
      end

      def similarity_params
        title_attr = translated_attribute(proposal.title)
        body_attr = translated_attribute(proposal.body)

        translations_enabled ? [title_attr, title_attr, body_attr, body_attr] : [title_attr, body_attr]
      end
    end
  end
end
