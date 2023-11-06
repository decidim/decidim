# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A form object used to create conference user roles from the admin dashboard.
      #
      class ConferenceUserRoleForm < Decidim::Admin::ParticipatorySpaceAdminUserForm
        mimic :conference_user_role

        def scope = "decidim.admin.models.conference_user_role.roles"
      end
    end
  end
end
