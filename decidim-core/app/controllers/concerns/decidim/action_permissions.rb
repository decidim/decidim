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

    def authorize_action!(action_name, redirect_url: nil)
      authorizer = action_authorizer(action_name)

      authorizer.on(:ok) { return true }

      authorizer.on(:missing) do |name|
        redirect_to decidim.new_authorization_path(handler: name)
      end

      authorizer.on(:invalid)  |fields| do
        raise "Unauthorized because #{fields.join}"
      end

      authorizer.on(:incomplete) do |fields|
        raise "Incomplete because #{fields.join}"
      end

      authorizer.authorize
    end

    def action_authorized?(action_name)
      authorizer = action_authorizer(action_name)
      authorizer.on(:ok) { return true }
      authorizer.authorize
      false
    end

    def action_authorizer(action_name)
      ActionAuthorizer.new(current_user, current_feature, action_name)
    end
  end
end
