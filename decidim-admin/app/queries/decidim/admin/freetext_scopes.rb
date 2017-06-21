# frozen_string_literal: true

module Decidim
  module Admin
    # This query searches scopes by name.
    class FreetextScopes < Rectify::Query
      # Syntactic sugar to initialize the class and return the queried objects.
      #
      # organization - an Organization context for the scope search
      # lang - the language code to be used for the search
      # text - the text to be searched in scopes names
      def self.for(organization, lang, text)
        new(organization, lang, text).query
      end

      # Initializes the class.
      #
      # organization - an Organization context for the scope search
      # lang - the language code to be used for the search
      # text - the text to be searched in scopes names
      def initialize(organization, lang, text)
        @organization = organization
        @lang = lang
        @text = text
      end

      # Finds scopes in the given organization and language whose name begins with the indicated text.
      #
      # Returns an ActiveRecord::Relation.
      def query
        @organization.scopes.where("name->>? ilike ?", @lang, @text + "%")
      end
    end
  end
end
