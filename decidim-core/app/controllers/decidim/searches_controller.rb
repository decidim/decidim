# frozen_string_literal: true

module Decidim
  class SearchesController < Decidim::ApplicationController
    include Rectify::ControllerHelpers
    skip_authorization_check
    helper_method :term

    def index
      Search.call(term, current_organization) do
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
  end
end
