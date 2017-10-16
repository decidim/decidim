# frozen_string_literal: true

module Decidim
  module Admin
    module Abilities
      # Defines the abilities for a user with role 'user_manager' in the admin section.
      # Intended to be used with `cancancan`.
      class UserManagerAbility < Decidim::Abilities::UserManagerAbility
        def define_abilities
          super

          can :manage, :managed_users

          can :impersonate, Decidim::User do |user|
            user.managed?
          end

          can :promote, Decidim::User do |user|
            user.managed?
          end
        end
      end
    end
  end
end
