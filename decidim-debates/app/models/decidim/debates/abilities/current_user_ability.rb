# frozen_string_literal: true

module Decidim
  module Debates
    module Abilities
      # Defines the abilities related to debates for a logged in user.
      # Intended to be used with `cancancan`.
      class CurrentUserAbility
        include CanCan::Ability

        attr_reader :user, :context

        def initialize(user, context)
          return unless user

          @user = user
          @context = context

          can :create, Debate if authorized?(:create) && creation_enabled?
          can :report, Debate
        end

        private

        def authorized?(action)
          return unless component

          ActionAuthorizer.new(user, component, action).authorize.ok?
        end

        def creation_enabled?
          return unless current_settings
          current_settings.creation_enabled?
        end

        def current_settings
          context.fetch(:current_settings, nil)
        end

        def component
          component = context.fetch(:current_component, nil)
          return nil unless component && component.manifest.name == :debates

          component
        end
      end
    end
  end
end
