# frozen_string_literal: true
module Decidim
  module Admin
    # A form object used to create participatory process user roles from the
    # admin dashboard.
    #
    class ParticipatoryProcessUserRoleForm < Form
      mimic :participatory_process_user_role

      attribute :email, String

      validates :email, presence: true
    end
  end
end
