# frozen_string_literal: true

module Decidim
  module Initiatives
    # This query searches scopes by name.
    class FreetextInitiativeTypes < Decidim::Query
      # Syntactic sugar to initialize the class and return the queried objects.
      #
      # organization - an Organization context for the initiative type search
      # lang - the language code to be used for the search
      # text - the text to be searched in initiative type titles
      def self.for(organization, lang, text)
        new(organization, lang, text).query
      end

      # Initializes the class.
      #
      # organization - an Organization context for the initiative type search
      # lang - the language code to be used for the search
      # text - the text to be searched in initiative type titles
      def initialize(organization, lang, text)
        @organization = organization
        @lang = lang
        @text = text
      end

      # Finds scopes in the given organization and language whose name begins with the indicated text.
      #
      # Returns an ActiveRecord::Relation.
      def query
        return InitiativesType.where(organization: @organization) if @text.blank?

        InitiativesType
          .where(organization: @organization)
          .where("title->>? ilike ?", @lang, "#{@text}%")
      end
    end
  end
end
