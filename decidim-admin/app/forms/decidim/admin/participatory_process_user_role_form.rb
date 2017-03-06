# frozen_string_literal: true
module Decidim
  module Admin
    # A form object used to create participatory process user roles from the
    # admin dashboard.
    #
    class ParticipatoryProcessUserRoleForm < Form
      mimic :participatory_process_user_role

      attribute :name, String
      attribute :email, String
      attribute :role, String

      validates :email, :role, presence: true
      validates :name, presence: true
      validates :role, inclusion: { in: ParticipatoryProcessUserRole::ROLES }
    end
  end
end
