# frozen_string_literal: true

module Decidim
  # A command that will act as a search service, with all the business logic for performing searches.
  class Search < Rectify::Command
    ACCEPTED_FILTERS = [:decidim_scope_id].freeze

    attr_reader :term, :results

    # Public: Initializes the command.
    #
    # @param term: The term to search for.
    # @param organization: The Organization to which the results are constrained.
    # @param filters: (optional) A Hash of SearchableResource attributes to filter for.
    # @param page_params: (optional) A Hash with `page` and `per_page` options to paginate.
    def initialize(term, organization, filters = {}, page_params = {})
      @term = term
      @organization = organization
      @filters = filters.with_indifferent_access
      @page_params = page_params
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid, together with the search results.
    # - :invalid if something failed and couldn't proceed.
    #
    # Returns nothing.
    def call
      search_results = Decidim::Searchable.searchable_resources.inject({}) do |results_by_type, (class_name, klass)|
        query = SearchableResource.where(organization: @organization, locale: I18n.locale)
        query = query.where(resource_type: class_name)

        clean_filters.each_pair do |attribute_name, value|
          query = query.where(attribute_name => value)
        end

        query = query.order("datetime DESC")
        query = query.global_search(I18n.transliterate(term)) if term.present?

        result_ids = query.pluck(:resource_id)
        results_count = result_ids.count
        results = ApplicationRecord.none

        if @filters[:resource_type].present?
          results = paginate(klass.order_by_id_list(result_ids)) if @filters["resource_type"] == class_name
        else
          results = klass.order_by_id_list(result_ids.take(4))
        end

        results_by_type.update(class_name => {
                                 count: results_count,
                                 results: results
                               })
      end
      broadcast(:ok, search_results)
    end

    private

    attr_reader :page_params

    def paginate(collection)
      return collection if page_params.blank?
      collection.page(page_params[:page]).per(page_params[:per_page])
    end

    def clean_filters
      @filters.select do |attribute_name, value|
        ACCEPTED_FILTERS.include?(attribute_name.to_sym) && value.present?
      end
    end
  end
end
