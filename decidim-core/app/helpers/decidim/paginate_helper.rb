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
      return if collection.total_pages <= 1

      per_page = (params[:per_page] || paginate_params[:per_page] || Decidim::Paginable::OPTIONS.first).to_i

      content_tag :div, class: "flex flex-col-reverse md:flex-row items-center justify-between gap-1 py-8 md:py-16 md:flex-wrap", data: { pagination: "" } do
        template = ""
        template += render(partial: "decidim/shared/results_per_page", locals: { per_page: }, formats: [:html]) if collection.total_pages.positive?
        template += paginate collection, window: 2, outer_window: 1, theme: "decidim", params: pagination_params(paginate_params)
        template.html_safe
      end
    end

    private

    def pagination_params(paginate_params)
      request_params = params.to_unsafe_h.except("locale", :locale)
      request_params["q"] = request_params["q"].except("locale", :locale) if request_params["q"].is_a?(Hash)
      request_params[:locale] = nil if admin_controller_with_locale_prefix?
      request_params.merge(paginate_params)
    end

    def admin_controller_with_locale_prefix?
      request.path_parameters[:locale].present? && controller_path.to_s.include?("/admin/")
    end
  end
end
