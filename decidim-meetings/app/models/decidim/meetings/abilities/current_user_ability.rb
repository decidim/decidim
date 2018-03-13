# frozen_string_literal: true

module Decidim
  module Meetings
    module Abilities
      # Defines the abilities related to meetings for a logged in user.
      # Intended to be used with `cancancan`.
      class CurrentUserAbility
        include CanCan::Ability

        attr_reader :user, :context

        def initialize(user, context)
          return unless user

          @user = user
          @context = context

          can :join, Meeting do |meeting|
            authorized?(:join) && meeting.registrations_enabled?
          end

          can :leave, Meeting, &:registrations_enabled?
        end

        private

        def authorized?(action)
          return unless component

          ActionAuthorizer.new(user, component, action).authorize.ok?
        end

        def component
          component = context.fetch(:current_component, nil)
          return nil unless component && component.manifest.name == :meetings

          component
        end
      end
    end
  end
end
