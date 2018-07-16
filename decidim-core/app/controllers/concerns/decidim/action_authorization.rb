# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module ActionAuthorization
    extend ActiveSupport::Concern

    included do
      helper_method :action_authorized_to
    end

    private

    def action_authorized_to(action, resource: nil)
      action_authorization_cache[action_authorization_cache_key(action, resource)] ||=
        ::Decidim::ActionAuthorizer.new(current_user, action, resource&.component || current_component, resource).authorize
    end

    def action_authorization_cache
      request.env["decidim.action_authorization_cache"] ||= {}
    end

    def action_authorization_cache_key(action, resource)
      if resource && !resource.permissions.nil?
        "#{action}-#{resource.component.id}-#{resource.resource_manifest.name}-#{resource.id}"
      else
        "#{action}-#{current_component.id}"
      end
    end
  end
end
