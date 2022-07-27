# frozen_string_literal: true

module Decidim
  # Helper to paginate collections.
  module PaginateHelper
    # Displays pagination links for the given collection, setting the correct
    # theme. This mostly acts as a proxy for the underlying pagination engine.
    #
    # collection - a collection of elements that need to be paginated
    # paginate_params - a Hash with options to delegate to the pagination helper.
    def decidim_paginate(collection, paginate_params = {})
      return if collection.total_pages == 1

      content_tag :div, class: "flex flex-col-reverse md:flex-row items-center justify-between gap-1 py-8 md:py-16", data: { pagination: "" } do
        template = ""
        template += render partial: "decidim/shared/results_per_page.html"
        template += paginate collection, window: 2, outer_window: 1, theme: "decidim", params: paginate_params
        template.html_safe
      end
    end

    def per_page
      params[:per_page] || Decidim::Paginable::OPTIONS.first
    end
  end
end
