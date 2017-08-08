# frozen_string_literal: true

module Decidim
  module Abilities
    # Defines the abilities for an user with role 'user_manager'.
    # Intended to be used with `cancancan`.
    class UserManagerAbility
      include CanCan::Ability

      attr_reader :user

      def initialize(user, context)
        @user = user
        @context = context

        define_abilities if not_admin? && user_manager?
      end

      def define_abilities
        can :read, :admin_dashboard
        can :impersonate, :managed_users
      end

      # Whether the user is an admin or not.
      def not_admin?
        @user && !@user.admin?
      end

      # Whether the user has the user_manager role or not.
      def user_manager?
        @user.role? "user_manager"
      end
    end
  end
end
