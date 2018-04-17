# frozen_string_literal: true

module Decidim
  class SearchesController < Decidim::ApplicationController
    include Rectify::ControllerHelpers
    include FormFactory
    include FilterResource
    # include Orderable
    include Paginable

    skip_authorization_check

    helper Decidim::FiltersHelper
    helper_method :term

    def index
      Search.call(term, current_organization, filters) do
        on(:ok) do |results|
          expose(results: results)
        end
      end
    end

    #--------------------------------------------------------------

    private

    #--------------------------------------------------------------

    def default_filter_params
      {
        term: params[:term],
        resource_type: nil,
        decidim_scope_id: nil
      }
    end

    def term
      @term ||= params[:term]
    end

    def filters
      @filters ||= params[:filter]&.permit([:resource_type, :scope_id])&.to_h
    end
  end
end
