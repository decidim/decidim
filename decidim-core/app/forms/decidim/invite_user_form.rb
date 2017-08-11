# frozen_string_literal: true

module Decidim
  # A form object used to invite users to an organization.
  #
  class InviteUserForm < Form
    mimic :user

    attribute :email, String
    attribute :name, String
    attribute :invitation_instructions, String
    attribute :organization, Decidim::Organization
    attribute :invited_by, Decidim::User
    attribute :role, String

    validates :email, :name, :organization, :invitation_instructions, presence: true
    validates :role, inclusion: { in: Decidim::User::ROLES }

    validate :admin_uniqueness

    def email
      super&.downcase
    end

    def organization
      super || current_organization
    end

    def invited_by
      super || current_user
    end

    def available_roles_for_select
      Decidim::User::ROLES.map do |role|
        [
          I18n.t("models.user.fields.roles.#{role}", scope: "decidim.admin"),
          role
        ]
      end
    end

    private

    def admin_uniqueness
      errors.add(:email, :taken) if organization.admins.where(email: email).exists?
    end
  end
end
