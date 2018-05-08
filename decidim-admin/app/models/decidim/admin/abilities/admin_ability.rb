# frozen_string_literal: true

module Decidim
  module Admin
    module Abilities
      # Defines the abilities for a user in the admin section. Intended to be
      # used with `cancancan`.
      class AdminAbility < Decidim::Abilities::AdminAbility
        def define_abilities
          super

          can :read, :admin_log

          can :manage, Category
          can :manage, ParticipatoryProcessUserRole

          can [:create, :update, :index, :new, :read], StaticPage
          can [:create, :update, :index, :new, :destroy], NavbarLink

          can([:update_slug, :destroy], [StaticPage, StaticPageForm]) do |page|
            !StaticPage.default?(page.slug)
          end

          can([:read, :update], Decidim::Organization) do |organization|
            organization == user.organization
          end

          can :manage, Component
          can :manage, :admin_users

          can :read, :impersonatable_users

          can(:impersonate, Decidim::User) do |user_to_impersonate|
            available_authorization_handlers? &&
              !user_to_impersonate.admin? &&
              user_to_impersonate.roles.empty? &&
              Decidim::ImpersonationLog.active.where(admin: user).empty?
          end

          can(:promote, Decidim::User) do |user_to_promote|
            user_to_promote.managed? && Decidim::ImpersonationLog.active.where(admin: user).empty?
          end

          can :manage, Moderation
          can :manage, Attachment
          can :manage, AttachmentCollection
          can :manage, Scope
          can :manage, NavbarLink
          can :manage, ScopeType
          can :manage, Area
          can :manage, AreaType
          can :manage, Newsletter
          can :manage, :oauth_applications
          can :manage, OAuthApplication

          can [:create, :index, :new, :read, :invite], User

          can([:destroy], [User]) do |user_to_destroy|
            user != user_to_destroy
          end

          can [:index, :verify, :reject], UserGroup
          can [:index, :new, :create, :destroy], :officializations

          can :index, :authorization_workflows

          can [:index, :update], Authorization
        end

        private

        def available_authorization_handlers?
          user.organization.available_authorization_handlers.any?
        end
      end
    end
  end
end
