# frozen_string_literal: true

module Decidim
  class LocaleRouterDetector
    def initialize(request, params)
      @request = request
      @params = params
    end

    def locale
      available_locales.map(&:to_sym).include?(extracted_locale.to_sym) ? extracted_locale : default_locale
    end

    private

    attr_reader :request, :params

    def extracted_locale
      params[:locale] || request.parameters[:locale] || request.session[:user_locale] || I18n.locale
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
