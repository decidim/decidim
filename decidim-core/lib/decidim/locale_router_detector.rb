# frozen_string_literal: true

# Handle the locale redirects in the route files
# It tries to detect a place where the locale is being present, either as a GET parameter,
# or a session, or if there is nothing it will return the default locale of the organization.
module Decidim
  class LocaleRouterDetector
    def initialize(request, params)
      @request = request
      @input_params = params
    end

    def locale
      available_locales.map(&:to_sym).include?(extracted_locale.to_sym) ? extracted_locale : default_locale
    end

    private

    attr_reader :request, :input_params

    def extracted_locale
      input_params[:locale] || request.parameters[:locale].presence || request.session[:user_locale].presence || I18n.locale
    end

    def available_locales
      (organization || Decidim).available_locales
    end

    def default_locale
      (organization || Decidim).default_locale
    end

    def organization
      request.env["decidim.current_organization"]
    end
  end
end
