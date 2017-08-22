# frozen_string_literal: true

module Decidim
  module Admin
    module Abilities
      # Defines the abilities for a participatory process admin in the admin
      # section. Intended to be used with `cancancan`. This is not intended to
      # extend the base `Decidim::Abilities::BaseAbility` class, it should only
      # be used in the Admin engine.
      #
      # This ability will not apply to organization admins.
      class ParticipatoryProcessAdminAbility < Decidim::Abilities::ParticipatoryProcessAdminAbility
        def define_abilities
          super

          can :manage, ParticipatoryProcess do |process|
            can_manage_process?(process)
          end

          cannot :create, ParticipatoryProcess
          cannot :destroy, ParticipatoryProcess
        end

        def define_participatory_process_abilities
          super

          can :manage, Feature do |feature|
            can_manage_process?(feature.participatory_space)
          end

          can :manage, Category do |category|
            can_manage_process?(category.participatory_space)
          end

          can :manage, Attachment do |attachment|
            attachment.attached_to.is_a?(Decidim::ParticipatoryProcess) && can_manage_process?(attachment.attached_to)
          end

          can :manage, ParticipatoryProcessUserRole do |role|
            can_manage_process?(role.participatory_process) && role.user != @user
          end

          can :manage, Moderation do |moderation|
            can_manage_process?(moderation.participatory_space)
          end

          can :manage, ParticipatoryProcessStep do |step|
            can_manage_process?(step.participatory_process)
          end
        end
      end
    end
  end
end
