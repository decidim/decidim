# frozen_string_literal: true

module Decidim
  # A form object used to invite admins to an organization.
  #
  class InviteAdminForm < Form
    mimic :user

    attribute :email, String
    attribute :name, String
    attribute :invitation_instructions, String
    attribute :roles, Array[String]
    attribute :organization, Decidim::Organization, default: :current_organization
    attribute :invited_by, Decidim::User, default: :current_user

    validates :email, :name, :organization, :invitation_instructions, :roles, presence: true
    validate :admin_uniqueness

    def email
      super&.downcase
    end

    private

    def admin_uniqueness
      errors.add(:email, :taken) if organization.admins.where(email: email).exists?
    end
  end
end
