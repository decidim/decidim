# frozen_string_literal: true
module Decidim
  module Admin
    module Abilities
      # Defines the abilities for a user in the admin section. Intended to be
      # used with `cancancan`.
      class AdminUser
        include CanCan::Ability

        def initialize(user)
          return unless user && user.role?(:admin)

          can :manage, ParticipatoryProcess
          can :manage, ParticipatoryProcessStep
          can :manage, Category
          can :manage, ParticipatoryProcessUserRole
          can [:create, :update, :index, :new, :read], StaticPage
          can [:update_slug, :destroy], [StaticPage, StaticPageForm] do |page|
            !StaticPage.default?(page.slug)
          end
          can [:read, :update], Decidim::Organization do |organization|
            organization == user.organization
          end

          can :manage, Feature
          can :read, :admin_dashboard
          can :manage, Attachment
          can :manage, Scope
          can [:create, :index, :new, :read, :invite], User
          can [:destroy], [User] do |user_to_destroy|
            user != user_to_destroy
          end

          can [:index, :verify], UserGroup
        end
      end
    end
  end
end
