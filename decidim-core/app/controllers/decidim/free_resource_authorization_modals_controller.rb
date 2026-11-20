# frozen_string_literal: true

module Decidim
  class FreeResourceAuthorizationModalsController < Decidim::ApplicationController
    helper_method :authorizations, :authorize_action_path
    layout false

    def show
      enforce_permission_to :read, :authorization
      raise ActiveRecord::RecordNotFound if resource.blank?

      render template: "decidim/authorization_modals/show"
    end

    def authorize_action_path(handler_name)
      authorizations.status_for(handler_name).current_path(redirect_url: URI(request.referer).path)
    end

    private

    def resource
      @resource ||= if params[:resource_name] && params[:resource_id]
                      manifest = Decidim.find_resource_manifest(params[:resource_name])
                      model = manifest&.model_class
                      # Free resources are not tied to a component, so they must
                      # be scoped through their direct organization association.
                      model.where(organization: current_organization).find_by(id: params[:resource_id]) if model&.reflect_on_association(:organization)
                    end
    end

    def authorization_action
      @authorization_action ||= params[:authorization_action]
    end

    def authorizations
      @authorizations ||= action_authorized_to(authorization_action, resource: nil, permissions_holder: resource)
    end
  end
end
