# frozen_string_literal: true

module Decidim
  module Abilities
    # Defines the abilities for an admin user. Intended to be used with `cancancan`.
    class AdminAbility
      include CanCan::Ability

      attr_reader :user

      def initialize(user, context)
        @user = user
        @context = context

        define_abilities if admin?
      end

      def define_abilities
        can :read, :admin_dashboard
        can :read, Feature
        can :impersonate, :managed_users
      end

      def admin?
        @user && @user.admin?
      end
    end
  end
end
