# frozen_string_literal: true

module Decidim
  module Admin
    module Abilities
      # Defines the abilities for a collaborator user in the admin
      # section. Intended to be used with `cancancan`.
      class ParticipatoryProcessCollaborator
        include CanCan::Ability

        def initialize(user, _context)
          @user = user

          return unless user && !user.admin?

          can :manage, :admin_dashboard

          can :preview, ParticipatoryProcess do |process|
            participatory_processes.include?(process)
          end
        end

        def participatory_processes
          @participatory_processes ||= Decidim::ParticipatoryProcessesWithUserRole.for(@user, :collaborator)
        end
      end
    end
  end
end
