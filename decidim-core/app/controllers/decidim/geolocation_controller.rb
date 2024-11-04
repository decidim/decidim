# frozen_string_literal: true

module Decidim
  class GeolocationController < Decidim::ApplicationController
    include Decidim::AjaxPermissionHandler

    def locate
      enforce_permission_to :locate, :geolocation

      unless Decidim::Map.configured?
        return render(json: { message: I18n.t("not_configured", scope: "decidim.application.geocoding"), found: false }, status: :unprocessable_entity)
      end

      geocoder = Decidim::Map.utility(:geocoding, organization: current_organization)
      address = geocoder.address([params[:latitude], params[:longitude]])
      render json: { address:, found: address.present? }
    end
  end
end
