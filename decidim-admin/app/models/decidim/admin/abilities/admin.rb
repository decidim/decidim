# frozen_string_literal: true
module Decidim
  module Admin
    module Abilities
      class Admin
        include CanCan::Ability

        def initialize(user)
          return unless user.has_role?(:admin)

          can :create, Decidim::ParticipatoryProcess
        end
      end
    end
  end
end
