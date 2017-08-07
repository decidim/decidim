# frozen_string_literal: true

module Decidim
  # This query searches scopes by name.
  class FreetextScopes < Rectify::Query
    # Syntactic sugar to initialize the class and return the queried objects.
    #
    # organization - an Organization context for the scope search
    # lang - the language code to be used for the search
    # text - the text to be searched in scopes names
    # root - root scope
    def self.for(organization, lang, text, root = nil)
      new(organization, lang, text, root).query
    end

    # Initializes the class.
    #
    # organization - an Organization context for the scope search
    # lang - the language code to be used for the search
    # text - the text to be searched in scopes names
    def initialize(organization, lang, text, root = nil)
      @organization = organization
      @lang = lang
      @text = text
      @root = root
    end

    # Finds scopes in the given organization and language whose name begins with the indicated text.
    #
    # Returns an ActiveRecord::Relation.
    def query
      if @root
        @root.descendants.where("name->>? ilike ?", @lang, @text + "%")
      else
        @organization.scopes.where("name->>? ilike ?", @lang, @text + "%")
      end
    end
  end
end
