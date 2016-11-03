# frozen_string_literal: true
module Decidim
  module Admin
    module Abilities
      # Defines the abilities for a user in the admin section. Intended to be
      # used with `cancancan`.
      class Base
        include CanCan::Ability

        def initialize(user)
          merge ::Decidim::Ability.new(user)

          return unless ParticipatoryProcessUserRole.where(user: user).any?

          can :read, :admin_dashboard

          can :manage, ParticipatoryProcess do |process|
            ManageableParticipatoryProcessesForUser.new(user).query.include?(process)
          end
          cannot :create, ParticipatoryProcess
          cannot :destroy, ParticipatoryProcess

          can :manage, ParticipatoryProcessStep do |step|
            ManageableParticipatoryProcessesForUser.new(user).query.include?(step.participatory_process)
          end
        end
      end
    end
  end
end
