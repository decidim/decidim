# frozen_string_literal: true

module Decidim
  # A controller to allow users switching their locale.
  class LocalesController < Decidim::ApplicationController
    skip_before_action :store_current_location

    def create
      enforce_permission_to :create, :locales

      desired_locale = params["locale"] if params["locale"] && available_locales.include?(params["locale"])

      current_user.update!(locale: params["locale"]) if current_user && params["locale"] && available_locales.include?(params["locale"])

      redirect_to canonical_url(request.referer || "/", desired_locale || default_locale)
    end
  end
end
