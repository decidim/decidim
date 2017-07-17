# frozen_string_literal: true

module Decidim
  module Comments
    module Abilities
      # Defines the abilities related to comments for a logged in admin user.
      # Intended to be used with `cancancan`.
      class AdminUser < Decidim::Abilities::AdminUser
        def define_abilities
          super

          can :manage, Comment
          can :unreport, Comment
          can :hide, Comment
        end
      end
    end
  end
end
