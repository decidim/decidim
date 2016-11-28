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
          participatory_processes = ManageableParticipatoryProcessesForUser.for(user)
          return unless participatory_processes.any?

          can :read, :admin_dashboard

          can :manage, ParticipatoryProcess do |process|
            participatory_processes.include?(process)
          end

          cannot :create, ParticipatoryProcess
          cannot :destroy, ParticipatoryProcess

          can :manage, ParticipatoryProcessUserRole do |role|
            role.user != user
          end

          can :manage, ParticipatoryProcessAttachment do |step|
            participatory_processes.include?(step.participatory_process)
          end

          can :manage, ParticipatoryProcessStep do |step|
            participatory_processes.include?(step.participatory_process)
          end

          can :manage, Component do |component|
            participatory_processes.include?(component.participatory_process)
          end

          can :manage, Category do |category|
            participatory_processes.include?(category.participatory_process)
          end
        end
      end
    end
  end
end
