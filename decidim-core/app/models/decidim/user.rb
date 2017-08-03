# frozen_string_literal: true

require_dependency "devise/models/decidim_validatable"

module Decidim
  # A User is a citizen that wants to join the platform to participate.
  class User < ApplicationRecord
    MAXIMUM_AVATAR_FILE_SIZE = 5.megabytes

    devise :invitable, :database_authenticatable, :registerable, :confirmable,
           :recoverable, :rememberable, :trackable, :decidim_validatable,
           :omniauthable, omniauth_providers: [:facebook, :twitter, :google_oauth2],
                          request_keys: [:env], reset_password_keys: [:decidim_organization_id, :email]

    belongs_to :organization, foreign_key: "decidim_organization_id", class_name: "Decidim::Organization"
    has_many :authorizations, foreign_key: "decidim_user_id", class_name: "Decidim::Authorization", inverse_of: :user
    has_many :identities, foreign_key: "decidim_user_id", class_name: "Decidim::Identity"
    has_many :memberships, class_name: "Decidim::UserGroupMembership", foreign_key: :decidim_user_id
    has_many :user_groups, through: :memberships, class_name: "Decidim::UserGroup", foreign_key: :decidim_user_group_id

    validates :name, presence: true, unless: -> { deleted? }
    validates :locale, inclusion: { in: Decidim.available_locales.map(&:to_s) }, allow_blank: true
    validates :tos_agreement, acceptance: true, allow_nil: false, on: :create
    validates :avatar, file_size: { less_than_or_equal_to: MAXIMUM_AVATAR_FILE_SIZE }
    validates :email, uniqueness: { scope: :organization }, unless: -> { deleted? }
    mount_uploader :avatar, Decidim::AvatarUploader

    scope :not_deleted, -> { where(deleted_at: nil) }

    # Public: Allows customizing the invitation instruction email content when
    # inviting a user.
    #
    # Returns a String.
    attr_accessor :invitation_instructions

    # Public: returns the user's name or the default one
    def name
      super || I18n.t("decidim.anonymous_user")
    end

    # Check if the user account has been deleted or not
    def deleted?
      deleted_at.present?
    end

    # Check if the user exists with the given email and the current organization
    #
    # warden_conditions - A hash with the authentication conditions
    #                   * email - a String that represents user's email.
    #                   * env - A Hash containing environment variables.
    # Returns a User.
    def self.find_for_authentication(warden_conditions)
      organization = warden_conditions.dig(:env, "decidim.current_organization")
      where(
        email: warden_conditions[:email],
        decidim_organization_id: organization.id
      ).first
    end

    protected

    # Overrides devise email required validation.
    # If the user has been deleted the email field is not required anymore.
    def email_required?
      !deleted?
    end

    private

    # Changes default Devise behaviour to use ActiveJob to send async emails.
    def send_devise_notification(notification, *args)
      devise_mailer.send(notification, self, *args).deliver_later
    end
  end
end
