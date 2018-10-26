# frozen_string_literal: true

module Decidim
  # This cell renders the profile of the given membership in the admin section.
  # It includes links to manage the membership: promote/demote admin, remove
  # from group.
  class UserGroupAdminMembershipProfileCell < Decidim::UserGroupMembershipProfileCell
    delegate :user, to: :model

    def admin_membership?
      model.role == "admin"
    end
  end
end
