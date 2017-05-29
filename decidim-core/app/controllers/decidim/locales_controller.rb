# frozen_string_literal: true

require_dependency "decidim/application_controller"

module Decidim
  # A controller to allow users switching their locale.
  class LocalesController < ApplicationController
    authorize_resource :locales, class: false

    def create
      if current_user && params["locale"] && available_locales.include?(params["locale"])
        current_user.update_attribute(:locale, params["locale"])
      end

      redirect_to referer_with_new_locale
    end

    private

    def referer_with_new_locale
      uri = URI(request.referrer || "/")
      query = uri.query.to_s.gsub(/locale\=[a-zA-Z\-]{2,5}/, "")
      params = URI.decode_www_form(query) << ["locale", current_locale]
      uri.query = URI.encode_www_form(params)

      uri.to_s
    end
  end
end
