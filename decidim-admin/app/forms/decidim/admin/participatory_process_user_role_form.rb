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
      attribute :roles, Array[String]

      validates :email, :roles, presence: true
      validates :roles, length: { minimum: 1, maximum: 1 }
      validates :name, presence: true, if: :is_process_admin?

      private

      def is_process_admin?
        roles.include?("process_admin")
      end
    end
  end
end
