# frozen_string_literal: true

module Decidim
  module Initiatives
    class AuthorizationSignModalsController < Decidim::Initiatives::ApplicationController
      include Decidim::Initiatives::NeedsInitiative

      helper_method :authorizations, :authorize_action_path
      layout false

      def show
        render template: "decidim/authorization_modals/show"
      end

      private

      def authorize_action_path(handler_name)
        authorizations.status_for(handler_name).current_path(redirect_url: URI(request.referer).path)
      end

      def authorizations
        @authorizations ||= action_authorized_to("vote", resource: current_initiative, permissions_holder: current_initiative.type)
      end
    end
  end
end
