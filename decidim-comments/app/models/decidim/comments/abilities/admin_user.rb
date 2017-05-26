# frozen_string_literal: true

module Decidim
  module Comments
    module Abilities
      # Defines the abilities related to comments for a logged in admin user.
      # Intended to be used with `cancancan`.
      class AdminUser
        include CanCan::Ability

        attr_reader :user, :context

        def initialize(user, context)
          return unless user && user.role?(:admin)

          @user = user
          @context = context

          can :manage, Comment
          can :unreport, Comment
          can :hide, Comment
        end
      end
    end
  end
end
