# frozen_string_literal: true

module Decidim
  # Helper that provides methods for managing Ransak related params.
  module RansakHelper
    # Returns the params to be setted to :q.
    def ransak_params_for_query(options = {})
      return options unless params["q"]
      params["q"].to_unsafe_h.merge(options)
    end
    # Returns the ransak params for :q, but without the given +param+.
    def ransak_params_for_query_without(param = "")
      return params["q"] if param.blank?
      params["q"].to_unsafe_h.except(param)
    end
  end
end
