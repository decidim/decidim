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

        def initialize(user, context)
          @user = user
          @context = context

          define_abilities if @user && !@user.admin?
        end

        def define_abilities
          can :read, :admin_dashboard

          can :manage, ParticipatoryProcess do |process|
            can_manage_process?(process)
          end

          cannot :create, ParticipatoryProcess
          cannot :destroy, ParticipatoryProcess

          define_participatory_process_abilities if current_participatory_process && can_manage_process?(current_participatory_process)
        end

        def define_participatory_process_abilities
          can :manage, Feature do |feature|
            can_manage_process?(feature.participatory_process)
          end

          can :manage, ParticipatoryProcessUserRole do |role|
            can_manage_process?(role.participatory_process) && role.user != @user
          end
        end

        def current_participatory_process
          @current_participatory_process ||= @context[:current_participatory_process]
        end

        def participatory_processes_with_admin_role
          @participatory_processes ||= Decidim::ParticipatoryProcessesWithUserRole.for(@user, :admin)
        end

        def can_manage_process?(process)
          participatory_processes_with_admin_role.include? process
        end
      end
    end
  end
end

          # can :manage, Moderation do |moderation|
          #   participatory_processes.include?(moderation.participatory_process)
          # end

          # can :manage, Attachment do |attachment|
          #   participatory_processes.include?(attachment.attached_to)
          # end

          # can :manage, ParticipatoryProcessStep do |step|
          #   participatory_processes.include?(step.participatory_process)
          # end

          # can :manage, Category do |category|
          #   participatory_processes.include?(category.participatory_process)
          # end