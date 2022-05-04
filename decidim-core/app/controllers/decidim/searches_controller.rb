# frozen_string_literal: true

module Decidim
  class SearchesController < Decidim::ApplicationController
    include Decidim::ControllerHelpers
    include FormFactory
    include FilterResource
    include Paginable

    helper Decidim::FiltersHelper
    helper_method :term

    def index
      Search.call(term, current_organization, filters, page_params) do
        on(:ok) do |results|
          results_count = results.sum { |results_by_type| results_by_type.last[:count] }
          expose(sections: results, results_count: results_count)
        end
      end
    end

    private

    def default_filter_params
      {
        term: params[:term],
        with_resource_type: nil,
        with_space_state: nil,
        decidim_scope_id_eq: nil
      }
    end

    def term
      @term ||= filter_params[:term]
    end

    def filters
      filter_params
    end

    def page_params
      {
        per_page: per_page,
        page: params[:page]
      }
    end
  end
end
