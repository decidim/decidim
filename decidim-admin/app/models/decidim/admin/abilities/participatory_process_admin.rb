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

        def initialize(user, _context)
          @user = user

          return unless user && !user.role?(:admin) && !user.role?(:collaborator)

          can :read, :admin_dashboard do
            participatory_processes.any?
          end

          can :manage, ParticipatoryProcess do |process|
            participatory_processes.include?(process)
          end

          cannot :create, ParticipatoryProcess
          cannot :destroy, ParticipatoryProcess

          cannot :manage, :admin_users

          can :manage, ParticipatoryProcessUserRole do |role|
            role.user != user
          end

          can :manage, Attachment do |attachment|
            participatory_processes.include?(attachment.attached_to)
          end

          can :manage, ParticipatoryProcessStep do |step|
            participatory_processes.include?(step.participatory_process)
          end

          can :manage, Feature do |feature|
            participatory_processes.include?(feature.participatory_process)
          end

          can :manage, Category do |category|
            participatory_processes.include?(category.participatory_process)
          end
        end

        def participatory_processes
          @participatory_processes ||= ManageableParticipatoryProcessesForUser.for(@user)
        end
      end
    end
  end
end
