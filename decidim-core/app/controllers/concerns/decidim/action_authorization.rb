# frozen_string_literal: true
require "active_support/concern"

module Decidim
  module ActionAuthorization
    extend ActiveSupport::Concern

    included do
      helper_method :authorize_action_path, :action_authorization
    end

    def authorize_action!(action_name, redirect_url: nil)
      @action_authorizations ||= {}
      @action_authorizations[action_name] = action_authorizer(action_name).authorize
      status = @action_authorizations[action_name]

      return if status.ok?
      raise "Unauthorized" if status.code == :invalid

      redirect_to authorize_action_path_from_status(status, redirect_url)
    end

    def action_authorization(action_name)
      action_authorizer(action_name).authorize
    end

    def action_authorizer(action_name)
      ActionAuthorizer.new(current_user, current_feature, action_name)
    end

    def authorize_action_path(action_name, redirect_url: nil)
      redirect_url ||= request.path

      authorize_action_path_from_status(
        action_authorization(action_name),
        redirect_url: redirect_url
      )
    end

    def authorize_action_path_from_status(status, redirect_url: nil)
      decidim.new_authorization_path(
        handler: status.data[:handler],
        redirect_url: redirect_url
      )
    end
  end
end
