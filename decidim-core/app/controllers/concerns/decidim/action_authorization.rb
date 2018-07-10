# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module ActionAuthorization
    extend ActiveSupport::Concern

    included do
      helper_method :action_authorized_to
    end

    private

    def action_authorized_to(action)
      _action_authorization_cache["#{current_component.id}-#{action}"] ||= ::Decidim::ActionAuthorizer.new(current_user, current_component, action).authorize
    end

    def _action_authorization_cache
      request.env["decidim.action_authorization_cache"] ||= {}
    end
  end
end
