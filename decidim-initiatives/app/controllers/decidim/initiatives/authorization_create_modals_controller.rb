# frozen_string_literal: true

module Decidim
  module Initiatives
    class AuthorizationCreateModalsController < Decidim::Initiatives::ApplicationController
      helper_method :authorizations, :authorize_action_path
      layout false

      def show
        @initiative_type = Decidim::InitiativesType.find_by(id: params[:slug])
        render template: "decidim/authorization_modals/show"
      end

      private

      def authorize_action_path(handler_name)
        authorizations.status_for(handler_name).current_path(redirect_url: URI(request.referer).path)
      end

      def authorizations
        @authorizations ||= action_authorized_to("create", permissions_holder: @initiative_type)
      end
    end
  end
end
