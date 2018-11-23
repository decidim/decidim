# frozen_string_literal: true

module Decidim
  # This cell renders the reuslts of the global search page.
  class SearchResultsCell < Decidim::ViewModel
    include Decidim::SearchesHelper
    include Decidim::CardHelper

    def show
      render :show
    end

    def sections
      model
    end

    def sections_to_render
      return sections.slice(selected_resource_type) if has_selected_resource_type?
      sections
    end

    def params
      options[:params]
    end

    def selected_resource_type
      params.dig(:filter, :resource_type)
    end

    def has_selected_resource_type?
      selected_resource_type.present?
    end
  end
end
