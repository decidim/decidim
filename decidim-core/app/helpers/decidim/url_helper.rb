# frozen_string_literal: true

module Decidim
  # Helper that sanitizes the parameters used to generate URLs.
  module UrlHelper
    # Rails uses these options to build URLs. Allowing user-controlled values
    # for them can change the generated URL's scheme, host, or path.
    RESERVED_URL_OPTIONS = (ActionDispatch::Routing::RouteSet::RESERVED_OPTIONS + [:path_params]).freeze

    # Removes the Rails URL generation options from the given parameters.
    #
    # params - An ActionController::Parameters or a Hash.
    #
    # Returns a HashWithIndifferentAccess without the reserved URL options.
    def decidim_url_params(params)
      Decidim::UrlHelper.sanitize_params(params)
    end

    def self.sanitize_params(params)
      params = params.to_unsafe_h if params.respond_to?(:to_unsafe_h)
      params.with_indifferent_access.except(*RESERVED_URL_OPTIONS)
    end
  end
end
