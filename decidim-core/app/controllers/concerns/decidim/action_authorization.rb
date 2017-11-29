# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module ActionAuthorization
    extend ActiveSupport::Concern

    included do
      helper_method :authorize_action_path, :action_authorization
    end

    # Public: Authorizes an action of a feature given an action name.
    #
    # action_name  - The action name to authorize. Actions are set up on the
    #                feature's permissions panel.
    # redirect_url - Url to be redirected to when the authorization is finished.
    def authorize_action!(action_name, redirect_url: nil)
      status = action_authorization(action_name)

      return if status.ok?
      raise Unauthorized if status.code == :invalid

      redirect_to authorize_action_path(action_name, redirect_url: redirect_url)
    end

    # Public: Returns the authorization object for an authorization.
    #
    # action_name - The action to authorize against.
    #
    # Returns an ActionAuthorizer::AuthorizationStatus
    def action_authorization(action_name)
      @action_authorizations ||= {}

      @action_authorizations[action_name] = _action_authorizer(action_name).authorize
    end

    # Public: Returns the authorization path for a failed authorization with
    # the populated redirect url.
    #
    # action_name - The action name to authorize against.
    # redirect_url - The url to redirect to when finished.
    #
    # Returns a String.
    def authorize_action_path(action_name, redirect_url: nil)
      redirect_url ||= request.path

      action_authorization(action_name).current_path(redirect_url: redirect_url)
    end

    def _action_authorizer(action_name)
      ::Decidim::ActionAuthorizer.new(current_user, current_feature, action_name)
    end

    class Unauthorized < StandardError; end
  end
end
