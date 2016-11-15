# frozen_string_literal: true
module Decidim
  module Admin
    module Abilities
      # Defines the abilities for a user in the admin section. Intended to be
      # used with `cancancan`.
      class AdminUser
        include CanCan::Ability

        def initialize(user)
          return unless user
          return unless user.role?(:admin)

          can :manage, ParticipatoryProcess
          can :manage, ParticipatoryProcessStep
          can :manage, ParticipatoryProcessUserRole
          can [:create, :update, :index, :new, :read], StaticPage
          can [:update_slug, :destroy], [StaticPage, StaticPageForm] do |page|
            !StaticPage.default?(page.slug)
          end
          can :read, :admin_dashboard
        end
      end
    end
  end
end
