# frozen_string_literal: true

module Decidim
  class LocaleRouter
    def initialize(request, params)
      @request = request
      @params = params
    end

    def locale
      I18n.available_locales.include?(extracted_locale.to_sym) ? extracted_locale : I18n.locale
    end

    private

    attr_reader :request, :params

    def extracted_locale
      params[:locale] || request.parameters[:locale] || request.session[:user_locale] || I18n.locale
    end
  end
end
