# frozen_string_literal: true
require "active_support/concern"

module Decidim
  module ActionPermissions
    extend ActiveSupport::Concern

    class_methods do
      def authorize_action!(action_name, *options)
        before_action(*options) do
          authorize_action! action_name
        end
      end
    end

    def authorize_action!(action_name, redirect_url: request.referer)
      result = action_authorizer(action_name).authorize
      return true if result.ok?

      case result.status
      when :missing
        flash[:notice] = "Please authorize"
        redirect_to decidim.new_authorization_path(handler: result.data[:handler], redirect_url: redirect_url)
      when :invalid
        flash[:alert] = "Invalid"
        redirect_to redirect_url
      when :incomplete
        flash[:notice] = "Incomplete"
        redirect_to decidim.edit_authorization_path(result.data[:handler], redirect_url: redirect_url)
      end
    end

    def action_authorization(action_name)
      action_authorizer(action_name).authorize
    end

    def action_authorizer(action_name)
      ActionAuthorizer.new(current_user, current_feature, action_name)
    end
  end
end
