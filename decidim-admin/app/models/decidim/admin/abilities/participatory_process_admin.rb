# frozen_string_literal: true
module Decidim
  module Admin
    module Abilities
      # Defines the abilities for a participatory process admin in the admin
      # section. Intended to be used with `cancancan`. This is not intended to
      # extend the base `Decidim::Ability` class, it should only be used in the
      # Admin engine.
      #
      # This ability will not apply to organization admins.
      class ParticipatoryProcessAdmin
        include CanCan::Ability

        def initialize(user)
          return if user.role?(:admin)
          return unless ManageableParticipatoryProcessesForUser.for(user).any?

          can :read, :admin_dashboard

          can :manage, ParticipatoryProcess do |process|
            ManageableParticipatoryProcessesForUser.for(user).include?(process)
          end
          cannot :create, ParticipatoryProcess
          cannot :destroy, ParticipatoryProcess

          can :manage, ParticipatoryProcessUserRole do |role|
            role.user != user
          end

          can :manage, [ParticipatoryProcessStep, ParticipatoryProcessAttachment] do |step|
            ManageableParticipatoryProcessesForUser.for(user).include?(step.participatory_process)
          end
        end
      end
    end
  end
end
