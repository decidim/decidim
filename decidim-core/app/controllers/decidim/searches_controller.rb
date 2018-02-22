# frozen_string_literal: true

module Decidim
  class SearchesController < Decidim::ApplicationController
    skip_authorization_check

    def index
      @results= SearchableRsrc.global_search(params[:term])
    end

  end
end
