# frozen_string_literal: true

module Decidim
  module Abilities
    # Defines the abilities for a participatory process collaborator. Intended to be
    # used with `cancancan`.
    # This ability will not apply to organization admins.
    class ParticipatoryProcessCollaborator < ParticipatoryProcessUserRole
      # Overrides ParticipatoryProcessUserRole role method
      def role
        :collaborator
      end
    end
  end
end
