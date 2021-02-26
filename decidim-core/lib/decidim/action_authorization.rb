# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module ActionAuthorization
    extend ActiveSupport::Concern

    included do
      helper_method :action_authorized_to
    end

    private

    def action_authorized_to(action, resource: nil, permissions_holder: nil)
      action_authorization_cache[action_authorization_cache_key(action, resource, permissions_holder)] ||=
        ::Decidim::ActionAuthorizer.new(current_user, action, permissions_holder || resource&.component || current_component, resource).authorize
    end

    def action_authorization_cache
      request.env["decidim.action_authorization_cache"] ||= {}
    end

    def action_authorization_cache_key(action, resource, permissions_holder = nil)
      if resource && !resource.permissions.nil?
        "#{action}-#{resource.component.id}-#{resource.resource_manifest.name}-#{resource.id}"
      elsif resource && permissions_holder
        "#{action}-#{permissions_holder.class.name}-#{permissions_holder.id}-#{resource.resource_manifest.name}-#{resource.id}"
      elsif permissions_holder
        "#{action}-#{permissions_holder.class.name}-#{permissions_holder.id}"
      else
        "#{action}-#{current_component.id}"
      end
    end
  end
end
