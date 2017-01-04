# frozen_string_literal: true
module Decidim
  # Helper to paginate collections.
  module PaginateHelper
    # Displays booleans in a human way (yes/no, supporting i18n). Supports
    # `nil` values as `false`.
    #
    # boolean - a Boolean that will be displayed in a human way.
    def decidim_paginate(collection, paginate_params)
      # Kaminari uses url_for to generate the url, but this doesn't play nice with our engine system
      # and unless we remove these params they are added again as query string :(
      params.delete("participatory_process_id")
      params.delete("feature_id")

      paginate collection, theme: "decidim", params: paginate_params
    end
  end
end
