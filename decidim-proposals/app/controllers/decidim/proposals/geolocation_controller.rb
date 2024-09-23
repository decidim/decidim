# frozen_string_literal: true

module Decidim
  module Proposals
    class GeolocationController < Decidim::Proposals::ApplicationController
      # overwrite original rescue_from to ensure we print messages from ajax methods (update)
      rescue_from Decidim::ActionForbidden, with: :ajax_user_has_no_permission

      def locate
        enforce_permission_to :locate, :geolocation

        unless Decidim::Map.configured?
          return render(json: { message: I18n.t("not_configured", scope: "decidim.application.geocoding"), found: false }, status: :unprocessable_entity)
        end

        geocoder = Decidim::Map.utility(:geocoding, organization: current_organization)
        address = geocoder.address([params[:latitude], params[:longitude]])
        render json: { address:, found: address.present? }
      end

      private

      # Rescue ajax calls and print the update.js view which prints the info on the message ajax form
      # Only if the request is AJAX, otherwise behave as Decidim standards
      def ajax_user_has_no_permission
        return user_has_no_permission unless request.xhr?

        render json: { message: I18n.t("actions.unauthorized", scope: "decidim.core") }, status: :unprocessable_entity
      end
    end
  end
end
