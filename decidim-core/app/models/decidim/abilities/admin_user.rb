# frozen_string_literal: true

module Decidim
  module Abilities
    # Defines the abilities for an admin user. Intended to be used with `cancancan`.
    class AdminUser
      include CanCan::Ability

      def initialize(user, _context)
        @user = user

        define_abilities if admin?
      end

      def define_abilities
        can :read, :admin_dashboard
      end

      def admin?
        @user && @user.admin?
      end
    end
  end
end
