# frozen_string_literal: true
module Decidim
  module Admin
    module Abilities
      # Defines the abilities for a participatory process admin in the admin
      # section. Intended to be used with `cancancan`. This is not intended to
      # extend the base `Decidim::Ability` class, it should only be used in the
      # Admin engine.
      class ParticipatoryProcessAdmin
        include CanCan::Ability

        def initialize(user)
          return unless user.participatory_process_user_roles.any?

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
