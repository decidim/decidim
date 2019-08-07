# frozen_string_literal: true

module Decidim
  class SearchesController < Decidim::ApplicationController
    include Rectify::ControllerHelpers
    include FormFactory
    include FilterResource
    include Paginable

    helper Decidim::FiltersHelper
    helper_method :term

    def index
      Search.call(term, current_organization, filters, page_params) do
        on(:ok) do |results|
          # results.page(params[:page]).per(params[:per_page])
          results_count = results.sum { |results_by_type| results_by_type.last[:count] }
          expose(sections: results, results_count: results_count)
        end
      end
    end

    private

    def default_filter_params
      {
        term: params[:term],
        resource_type: nil,
        decidim_scope_id: nil
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
