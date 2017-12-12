# frozen_string_literal: true

require_dependency "devise/models/decidim_validatable"
require "valid_email2"

module Decidim
  # A User is a citizen that wants to join the platform to participate.
  class User < ApplicationRecord
    OMNIAUTH_PROVIDERS = [:facebook, :twitter, :google_oauth2, (:developer if Rails.env.development?)].compact
    ROLES = %w(admin user_manager).freeze

    devise :invitable, :database_authenticatable, :registerable, :confirmable,
           :recoverable, :rememberable, :trackable, :decidim_validatable,
           :omniauthable, omniauth_providers: OMNIAUTH_PROVIDERS,
                          request_keys: [:env], reset_password_keys: [:decidim_organization_id, :email]

    belongs_to :organization, foreign_key: "decidim_organization_id", class_name: "Decidim::Organization"
    has_many :identities, foreign_key: "decidim_user_id", class_name: "Decidim::Identity", dependent: :destroy
    has_many :memberships, class_name: "Decidim::UserGroupMembership", foreign_key: :decidim_user_id, dependent: :destroy
    has_many :user_groups, through: :memberships, class_name: "Decidim::UserGroup", foreign_key: :decidim_user_group_id
    has_many :follows, foreign_key: "decidim_user_id", class_name: "Decidim::Follow", dependent: :destroy
    has_many :notifications, foreign_key: "decidim_user_id", class_name: "Decidim::Notification", dependent: :destroy

    validates :name, presence: true, unless: -> { deleted? }
    validates :locale, inclusion: { in: :available_locales }, allow_blank: true
    validates :tos_agreement, acceptance: true, allow_nil: false, on: :create
    validates :avatar, file_size: { less_than_or_equal_to: ->(_record) { Decidim.maximum_avatar_size } }
    validates :email, uniqueness: { scope: :organization }, unless: -> { deleted? || managed? }
    validates :email, 'valid_email_2/email': { disposable: true }

    validate :all_roles_are_valid

    mount_uploader :avatar, Decidim::AvatarUploader

    scope :not_deleted, -> { where(deleted_at: nil) }
    scope :managed, -> { where(managed: true) }

    # Public: Allows customizing the invitation instruction email content when
    # inviting a user.
    #
    # Returns a String.
    attr_accessor :invitation_instructions

    # Checks if the user has the given `role` or not.
    #
    # role - a String or a Symbol that represents the role that is being
    #   checked
    #
    # Returns a boolean.
    def role?(role)
      roles.include?(role.to_s)
    end

    # Public: Returns the active role of the user
    def active_role
      admin ? "admin" : roles.first
    end

    # Public: returns the user's name or the default one
    def name
      super || I18n.t("decidim.anonymous_user")
    end

    # Check if the user account has been deleted or not
    def deleted?
      deleted_at.present?
    end

    def follows?(followable)
      Decidim::Follow.where(user: self, followable: followable).any?
    end

    def unread_conversations
      Decidim::Messaging::Conversation.unread_by(self)
    end

    # Check if the user exists with the given email and the current organization
    #
    # warden_conditions - A hash with the authentication conditions
    #                   * email - a String that represents user's email.
    #                   * env - A Hash containing environment variables.
    # Returns a User.
    def self.find_for_authentication(warden_conditions)
      organization = warden_conditions.dig(:env, "decidim.current_organization")
      find_by(
        email: warden_conditions[:email],
        decidim_organization_id: organization.id
      )
    end

    protected

    # Overrides devise email required validation.
    # If the user has been deleted or it is managed the email field is not required anymore.
    def email_required?
      return false if deleted? || managed?
      super
    end

    # Overrides devise password required validation.
    # If the user is managed the password field is not required anymore.
    def password_required?
      return false if managed?
      super
    end

    private

    # Changes default Devise behaviour to use ActiveJob to send async emails.
    def send_devise_notification(notification, *args)
      devise_mailer.send(notification, self, *args).deliver_later
    end

    def all_roles_are_valid
      errors.add(:roles, :invalid) unless roles.compact.all? { |role| ROLES.include?(role) }
    end

    def available_locales
      Decidim.available_locales.map(&:to_s)
    end
  end
end
