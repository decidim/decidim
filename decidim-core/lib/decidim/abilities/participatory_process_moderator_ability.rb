# frozen_string_literal: true

module Decidim
  module Abilities
    # Defines the abilities for a participatory process moderator. Intended to be
    # used with `cancancan`.
    # This ability will not apply to organization admins.
    class ParticipatoryProcessModeratorAbility < ParticipatoryProcessRoleAbility
      # Overrides ParticipatoryProcessRoleAbility role method
      def role
        :moderator
      end
    end
  end
end
