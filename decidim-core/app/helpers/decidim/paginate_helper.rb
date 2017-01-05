# frozen_string_literal: true
module Decidim
  # Helper to paginate collections.
  module PaginateHelper
    # Displays pagination links for the given collection, setting the correct
    # theme. This mostly acts as a proxy for the underlying pagination engine.
    #
    # collection - a collection of elements that need to be paginated
    # paginate_params - a Hash with options to delegate to the pagination helper.
    def decidim_paginate(collection, paginate_params)
      # Kaminari uses url_for to generate the url, but this doesn't play nice with our engine system
      # and unless we remove these params they are added again as query string :(
      # Please do not mix `params` with `paginate_params`. We're removing elements from the
      # global `params` object.
      params.delete("participatory_process_id")
      params.delete("feature_id")

      paginate collection, theme: "decidim", params: paginate_params
    end
  end
end
