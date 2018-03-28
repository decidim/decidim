# frozen_string_literal: true

module Decidim
  # Default permissions class for all components and spaces. It authorizes all
  # actions by any kind of user. Also works as a default implementation so other
  # components can inherit from it and get some cenvenience methods.
  class DefaultPermissions
    def initialize(user, permission_action, context)
      @user = user
      @permission_action = permission_action
      @context = context
    end

    def allowed?
      true
    end

    private

    attr_reader :user, :permission_action, :context

    def spaces_allows_user?
      return unless space.manifest.permissions_class
      space.manifest.permissions_class.new(user, permission_action, context).allowed?
    end

    def authorized?(permission_action)
      return unless component

      ActionAuthorizer.new(user, component, permission_action).authorize.ok?
    end

    def current_settings
      @current_settings ||= context.fetch(:current_settings, nil)
    end

    def component_settings
      @component_settings ||= context.fetch(:component_settings, nil)
    end

    def component
      @component ||= context.fetch(:current_component)
    end

    def space
      @space ||= component.participatory_space
    end
  end
end
