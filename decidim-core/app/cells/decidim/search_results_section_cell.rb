# frozen_string_literal: true

module Decidim
  # This cell renders a section on the global search results page.
  class SearchResultsSectionCell < Decidim::ViewModel
    include Decidim::SearchesHelper
    include Decidim::CardHelper
    include Decidim::CellsPaginateHelper
    include Decidim::Core::Engine.routes.url_helpers

    def show
      render :show
    end

    def class_name
      model.keys.first
    end

    def results_count
      @results_count ||= model.values.first[:count]
    end

    def results
      @results ||= model.values.first[:results]
    end

    def paginated?
      options[:is_paginated]
    end

    def last_section?
      options[:is_last_section]
    end
  end
end
