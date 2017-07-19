# frozen_string_literal: true

module Decidim
  module Admin
    module Abilities
      # Defines the abilities for a collaborator user in the admin
      # section. Intended to be used with `cancancan`.
      class ParticipatoryProcessCollaboratorAbility < Decidim::Abilities::ParticipatoryProcessCollaboratorAbility
        def define_abilities
          super

          can [:read, :preview], ParticipatoryProcess do |process|
            can_manage_process?(process)
          end
        end
      end
    end
  end
end
