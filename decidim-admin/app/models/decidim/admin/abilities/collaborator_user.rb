# frozen_string_literal: true

module Decidim
  module Admin
    module Abilities
      # Defines the abilities for a collaborator user in the admin
      # section. Intended to be used with `cancancan`.
      class CollaboratorUser
        include CanCan::Ability

        def initialize(user, _context)
          # TODO: Fix collaborators
          # return unless user && user.role?(:collaborator)
          return unless user

          can :manage, :admin_dashboard
          can :preview, ParticipatoryProcess
        end
      end
    end
  end
end
