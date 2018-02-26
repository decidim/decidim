# frozen_string_literal: true

module Decidim
  class SearchesController < Decidim::ApplicationController
    include Rectify::ControllerHelpers
    # include Paginable
    skip_authorization_check
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

    def term
      @term ||= params[:term]
    end

    def filters
      @filters ||= params[:filter]&.permit([:resource_type, :scope_id])&.to_h
    end
  end
end
