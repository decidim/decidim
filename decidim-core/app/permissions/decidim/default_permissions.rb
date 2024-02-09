# frozen_string_literal: true

module Decidim
  # Default permissions class for all components and spaces. It deauthorizes all
  # actions by any kind of user. Also works as a default implementation so other
  # components can inherit from it and get some convenience methods.
  class DefaultPermissions
    def initialize(user, permission_action, context = {})
      @user = user
      @permission_action = permission_action
      @context = context
    end

    def permissions
      permission_action
    end

    private

    attr_reader :user, :permission_action, :context

    def disallow!
      permission_action.trace(self.class.name, :disallowed)
      permission_action.disallow!
    end

    def allow!
      permission_action.trace(self.class.name, :allowed)
      permission_action.allow!
    end

    def toggle_allow(condition)
      condition ? allow! : disallow!
    end

    def read_participatory_space_action?
      permission_action.action == :read &&
        [:participatory_space, :component].include?(permission_action.subject)
    end

    def authorized?(permission_action, resource: nil)
      return unless resource || component
      return if component && resource && component != resource.component

      ActionAuthorizer.new(user, permission_action, component, resource).authorize.ok?
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
