# frozen_string_literal: true

module Decidim
  class FreeResourceAuthorizationModalsController < Decidim::ApplicationController
    helper_method :authorizations, :authorize_action_path
    layout false

    def show
      render template: "decidim/authorization_modals/show"
    end

    private

    def resource
      @resource ||= if params[:resource_name] && params[:resource_id]
                      manifest = Decidim.find_resource_manifest(params[:resource_name])
                      manifest&.model_class&.find_by(id: params[:resource_id])
                    end
    end

    def authorization_action
      @authorization_action ||= params[:authorization_action]
    end

    def authorize_action_path(handler_name)
      authorizations.status_for(handler_name).current_path(redirect_url: URI(request.referer).path)
    end

    def authorizations
      @authorizations ||= action_authorized_to(authorization_action, resource: nil, permissions_holder: resource)
    end
  end
end
