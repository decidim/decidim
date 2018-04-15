# frozen_string_literal: true

module Decidim
  module Admin
    module Abilities
      # Defines the abilities for a user with role 'user_manager' in the admin section.
      # Intended to be used with `cancancan`.
      class UserManagerAbility < Decidim::Abilities::UserManagerAbility
        def define_abilities
          super

          can :read, :impersonations

          can :impersonate, Decidim::User do
            available_authorization_handlers? && Decidim::ImpersonationLog.active.where(admin: user).empty?
          end

          can :promote, Decidim::User do |user_to_promote|
            user_to_promote.managed? && Decidim::ImpersonationLog.active.where(admin: user).empty?
          end
        end

        private

        def available_authorization_handlers?
          user.organization.available_authorization_handlers.any?
        end
      end
    end
  end
end
