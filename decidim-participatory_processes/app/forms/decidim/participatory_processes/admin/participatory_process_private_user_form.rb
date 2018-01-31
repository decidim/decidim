# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A form object used to create participatory process user roles from the
      # admin dashboard.
      #
      class ParticipatoryProcessPrivateUserForm < Form
        mimic :participatory_process_private_user

        attribute :name, String
        attribute :email, String

        validates :email, presence: true
        validates :name, presence: true
      end
    end
  end
end
