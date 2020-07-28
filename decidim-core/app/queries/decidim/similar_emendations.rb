# frozen_string_literal: true

module Decidim
  # Class used to retrieve similar emendations, scoped to the current component.
  class SimilarEmendations < Rectify::Query
    include Decidim::TranslationsHelper

    # Syntactic sugar to initialize the class and return the queried objects.
    #
    # amendment - Decidim::Amendment
    def self.for(amendment)
      new(amendment).query
    end

    # Initializes the class.
    #
    # amendment - Decidim::Amendment
    def initialize(amendment)
      @component = amendment.amendable.component
      @emendation = amendment.emendation
      @amender = amendment.amender
    end

    # Retrieves similar emendations
    def query
      emendation.class
                .where(component: component)
                .only_visible_emendations_for(amender, component)
                .published
                .not_hidden
                .where(
                  "GREATEST(#{title_similarity}, #{body_similarity}) >= ?",
                  emendation.title,
                  emendation.body,
                  amendable_module.similarity_threshold
                )
                .limit(amendable_module.similarity_limit)
    end

    private

    attr_reader :component, :emendation, :amender

    def amendable_module
      emendation.class.parent
    end

    def title_similarity
      "similarity(title::text, ?)"
    end

    def body_similarity
      "similarity(body::text, ?)"
    end
  end
end
