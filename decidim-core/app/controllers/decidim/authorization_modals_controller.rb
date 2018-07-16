# frozen_string_literal: true

module Decidim
  class AuthorizationModalsController < Decidim::ApplicationController
    helper_method :status, :authorize_action_path
    layout false

    def show; end

    private

    def resource
      @resource ||= if params[:resource_name] && params[:resource_id]
                      manifest = Decidim.find_resource_manifest(params[:resource_name])
                      manifest&.resource_scope(current_component)&.find_by(id: params[:resource_id])
                    end
    end

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
      @status ||= action_authorized_to(authorization_action, resource: resource)
    end
  end
end
