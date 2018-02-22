# frozen_string_literal: true

module Decidim
  class SearchesController < Decidim::ApplicationController
    #include Paginable
    skip_authorization_check
    helper_method :term

    def index
      @results = SearchableRsrc.global_search(term)
    end

    private

    def term
      @term ||= params[:term]
    end
  end
end
