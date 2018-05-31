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
          expose(results: results)
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
