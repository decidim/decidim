# frozen_string_literal: true

module Decidim
  class AuthorizationModalsController < Decidim::ApplicationController
    helper_method :status, :authorize_action_path
    layout false

    def show; end

    private

    def current_component
      @current_component ||= Decidim::Component.find(params[:component_id])
    end

    def authorization_action
      @authorization_action ||= params[:authorization_action]
    end

    def authorize_action_path
      status.current_path(redirect_url: URI(request.referer).path)
    end

    def status
      @status ||= ::Decidim::ActionAuthorizer.new(current_user, current_component, authorization_action).authorize
    end
  end
end
