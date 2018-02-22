# frozen_string_literal: true

module Decidim
  # A command that will act as a search service, with all the business logic for performing searches.
  class Search < Rectify::Command

    attr_reader :term, :results

    # Public: Initializes the command.
    #
    # @param term: The term to search for.
    def initialize(term, organization)
      @term = term
      @organization = organization
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid, together with the search results.
    # - :invalid if something failed and couldn't proceed.
    #
    # Returns nothing.
    def call
      query= SearchableRsrc.where(organization: @organization)
      @results= if term.present?
        query.global_search(term)
      else
        query.all
      end

      broadcast(:ok, @results)
    end

  end
end
