# frozen_string_literal: true

module Decidim
  # Helper that sanitizes the parameters used to generate URLs.
  module UrlHelper
    # Rails uses these options to build URLs. Allowing user-controlled values
    # for them can change the generated URL's scheme, host, or path. The
    # `_recall` and `use_route` options are handled before the route set
    # resolves the URL, so they are not part of RESERVED_OPTIONS.
    RESERVED_URL_OPTIONS = (
      ActionDispatch::Routing::RouteSet::RESERVED_OPTIONS + [:path_params, :_recall, :use_route]
    ).freeze

    # Removes the Rails URL generation options from the given parameters and
    # merges the extra parameters.
    #
    # The extra parameters are trusted values defined by the application, so
    # they take precedence over the request parameters. This allows forcing
    # routing options (such as the controller, the action or the format)
    # without letting a request parameter override them.
    #
    # params - An ActionController::Parameters or a Hash.
    # extra_params - A Hash with extra URL generation options.
    #
    # Returns a HashWithIndifferentAccess without the reserved URL options.
    def decidim_url_params(params, **extra_params)
      Decidim::UrlHelper.sanitize_params(params).merge(extra_params)
    end

    def self.sanitize_params(params)
      params = params.to_unsafe_h if params.respond_to?(:to_unsafe_h)
      params.with_indifferent_access.except(*RESERVED_URL_OPTIONS)
    end
  end
end
