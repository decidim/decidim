# frozen_string_literal: true

module Decidim
  # A command that will act as a search service, with all the business logic for performing searches.
  class Search < Rectify::Command
    ACCEPTED_FILTERS = [:resource_type, :decidim_scope_id].freeze

    attr_reader :term, :results

    # Public: Initializes the command.
    #
    # @param term: The term to search for.
    def initialize(term, organization, filters = {})
      @term = term
      @organization = organization
      @filters = filters
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid, together with the search results.
    # - :invalid if something failed and couldn't proceed.
    #
    # Returns nothing.
    def call
      query = SearchableResource.where(organization: @organization, locale: I18n.locale)
      @filters.each_pair do |attribute_name, value|
        query = query.where(attribute_name => value) if permit_filter?(attribute_name, value)
      end
      @results = if term.present?
                   query.global_search(I18n.transliterate(term))
                 else
                   query.all
                 end

      broadcast(:ok, @results.order("datetime DESC"))
    end

    private

    def permit_filter?(attribute_name, value)
      ACCEPTED_FILTERS.include?(attribute_name.to_sym) && value.present?
    end
  end
end
