# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A form object used to create conference user roles from the admin dashboard.
      #
      class ConferenceUserRoleForm < Form
        mimic :conference_user_role

        attribute :name, String
        attribute :email, String
        attribute :role, String

        validates :email, :role, presence: true
        validates :name, presence: true
        validates :role, inclusion: { in: Decidim::ConferenceUserRole::ROLES }

        def roles
          Decidim::ConferenceUserRole::ROLES.map do |role|
            [
              I18n.t(role, scope: "decidim.admin.models.conference_user_role.roles"),
              role
            ]
          end
        end
      end
    end
  end
end
