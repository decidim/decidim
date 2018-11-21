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
      Search.call(term, current_organization, filters) do
        on(:ok) do |results|
          # results.page(params[:page]).per(params[:per_page])
          results = results.to_a
          expose(sections: results.group_by(&:resource_type), results_count: results.count)
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
  end
end
