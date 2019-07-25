# frozen_string_literal: true

module Decidim
  module Consultations
    class AuthorizationVoteModalsController < Decidim::Consultations::ApplicationController
      include NeedsQuestion

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
        @authorizations ||= action_authorized_to(:vote, resource: nil, permissions_holder: current_question)
      end
    end
  end
end
