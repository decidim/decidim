# frozen_string_literal: true

module Decidim
  module Abilities
    # Defines the abilities for a participatory process admin. Intended to be
    # used with `cancancan`.
    # This ability will not apply to organization admins.
    class ParticipatoryProcessAdminUser < ParticipatoryProcessRoleUser
      # Overrides ParticipatoryProcessUserRole role method
      def role
        :admin
      end
    end
  end
end
