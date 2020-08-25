# frozen_string_literal: true

module Decidim
  # A helper to allow only Decidim params to be added to a link.
  # This is useful when we want to preserve the params from a search, ordering
  # or paginating results. Using this, we can link back to where the user was
  # at the show page.
  module FilterParamsHelper
    # Public: Builds a hash to be added to a _path or _url method with only
    # allowed params.
    #
    # params - An optional Hash with the values of the params. It will try to
    # get them from the controller if none are present.
    #
    # Returns a Hash.
    def filter_link_params(params = nil)
      return {} if params.blank? && (!respond_to?(:controller) || !controller.respond_to?(:params))

      params = controller.params.to_unsafe_h if params.blank?

      params.stringify_keys.slice(
        "order",
        "filter",
        "page",
        "per_page",
        "locale"
      )
    end
  end
end
