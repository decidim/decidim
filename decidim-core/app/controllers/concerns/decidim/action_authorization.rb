# frozen_string_literal: true
require "active_support/concern"

module Decidim
  module ActionAuthorization
    extend ActiveSupport::Concern

    included do
      helper_method :reauthorize_action_path, :action_authorization
    end

    def authorize_action!(action_name, redirect_url: nil)
      status = action_authorizer(action_name).authorize
      return if status.ok?
      raise "Unauthorized" if status.invalid?

      redirect_to reauthorize_action_path_from_status(status, redirect_url)
    end

    def action_authorization(action_name)
      action_authorizer(action_name).authorize
    end

    def action_authorizer(action_name)
      ActionAuthorizer.new(current_user, current_feature, action_name)
    end

    def reauthorize_action_path(action_name, redirect_url: nil)
      redirect_url ||= request.path

      reauthorize_action_path_from_status(
        action_authorization(action_name),
        redirect_url: redirect_url
      )
    end

    def reauthorize_action_path_from_status(status, redirect_url: nil)
      raise "Whatevers" unless status.reauthorize?

      decidim.new_authorization_path(
        handler: status.data[:handler],
        redirect_url: redirect_url
      )
    end
  end
end
