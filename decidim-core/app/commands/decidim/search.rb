# frozen_string_literal: true

module Decidim
  # A command that will act as a search service, with all the business logic for performing searches.
  class Search < Decidim::Command
    HIGHLIGHTED_RESULTS_COUNT = 4

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
    # - :invalid if something failed and could not proceed.
    #
    # Returns nothing.
    def call
      search_results = Decidim::Searchable.searchable_resources.inject({}) do |results_by_type, (class_name, klass)|
        result_ids = filtered_query_for(class_name).pluck(:resource_id)
        results_count = result_ids.count

        results = if filters[:with_resource_type].present? && filters[:with_resource_type] == class_name
                    paginate(klass.order_by_id_list(result_ids))
                  elsif filters[:with_resource_type].present?
                    ApplicationRecord.none
                  else
                    klass.order_by_id_list(result_ids.take(HIGHLIGHTED_RESULTS_COUNT))
                  end

        uncommentable_resources = uncommentable_resources(results) if results.present?
        if uncommentable_resources.present?
          results -= uncommentable_resources
          results_count -= uncommentable_resources.count
        end

        results_by_type.update(class_name => {
                                 count: results_count,
                                 results:
                               })
      end
      broadcast(:ok, search_results)
    end

    private

    attr_reader :page_params, :filters, :organization, :term

    def paginate(collection)
      return collection if page_params.blank?

      collection.page(page_params[:page]).per(page_params[:per_page])
    end

    def spaces_to_filter
      return nil if filters[:with_space_state].blank?

      Decidim.participatory_space_manifests.flat_map do |manifest|
        public_spaces = manifest.participatory_spaces.call(organization).public_spaces
        spaces = case filters[:with_space_state]
                 when "active"
                   public_spaces.active_spaces
                 when "future"
                   public_spaces.future_spaces
                 when "past"
                   public_spaces.past_spaces
                 else
                   public_spaces
                 end
        spaces.select(:id).to_a
      end
    end

    def filtered_query_for(class_name)
      query = SearchableResource.where(
        organization:,
        locale: I18n.locale,
        resource_type: class_name
      )

      if (spaces = spaces_to_filter)
        query = query.where(decidim_participatory_space: spaces)
      end

      query = query.order("datetime DESC")
      query = query.global_search(I18n.transliterate(term)) if term.present?
      query
    end

    def uncommentable_resources(results)
      results.where(id: results.select { |obj| related_uncommentable_resources?(obj) }.map(&:id))
    end

    def related_uncommentable_resources?(object)
      object.respond_to?(:commentable) && !object.commentable.commentable?
    end
  end
end
