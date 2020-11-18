# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A form object used to create participatory process user roles from the
      # admin dashboard.
      #
      class ParticipatoryProcessUserRoleForm < Form
        mimic :participatory_process_user_role

        attribute :name, String
        attribute :email, String
        attribute :role, String

        validates :name, :email, :role, presence: true
        validates :role, inclusion: { in: Decidim::ParticipatoryProcessUserRole::ROLES }

        validates :name, format: { with: UserBaseEntity::REGEXP_NAME }

        def roles
          Decidim::ParticipatoryProcessUserRole::ROLES.map do |role|
            [
              I18n.t(role, scope: "decidim.admin.models.participatory_process_user_role.roles"),
              role
            ]
          end
        end
      end
    end
  end
end
