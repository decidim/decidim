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

      validates :name, :email, presence: true

      validates :name, format: { with: /\A(?!.*[<>?%&\^*#@\(\)\[\]\=\+\:\;\"\{\}\\\|])/ }
      validate :admin_uniqueness

      def admin_uniqueness
        if context && context.current_organization && context.current_organization.admins.where(email: email).exists?
          errors.add(:email, :taken)
        end
      end
    end
  end
end
