# frozen_string_literal: true

module Decidim
  module Admin
    # A form object used to create participatory space private users from the
    # admin dashboard.
    #
    class ParticipatorySpacePrivateUserForm < Form
      mimic :participatory_space_private_user

      attribute :name, String
      attribute :email, String

      validates :email, presence: true
      validates :name, presence: true
    end
  end
end
