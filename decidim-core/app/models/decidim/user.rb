# frozen_string_literal: true

require_dependency "devise/models/decidim_validatable"
require_dependency "devise/models/decidim_newsletterable"
require "valid_email2"

module Decidim
  # A User is a citizen that wants to join the platform to participate.
  class User < ApplicationRecord
    include Nicknamizable
    include Resourceable
    include Decidim::Followable
    include Decidim::Loggable
    include Decidim::DataPortability
    include Decidim::Searchable

    OMNIAUTH_PROVIDERS = [:facebook, :twitter, :google_oauth2, (:developer if Rails.env.development?)].compact
    ROLES = %w(admin user_manager).freeze

    devise :invitable, :database_authenticatable, :registerable, :confirmable, :timeoutable,
           :recoverable, :rememberable, :trackable, :decidim_validatable,
           :decidim_newsletterable,
           :omniauthable, omniauth_providers: OMNIAUTH_PROVIDERS,
                          request_keys: [:env], reset_password_keys: [:decidim_organization_id, :email],
                          confirmation_keys: [:decidim_organization_id, :email]

    belongs_to :organization, foreign_key: "decidim_organization_id", class_name: "Decidim::Organization"
    has_many :identities, foreign_key: "decidim_user_id", class_name: "Decidim::Identity", dependent: :destroy
    has_many :memberships, class_name: "Decidim::UserGroupMembership", foreign_key: :decidim_user_id, dependent: :destroy
    has_many :user_groups, through: :memberships, class_name: "Decidim::UserGroup", foreign_key: :decidim_user_group_id
    has_many :notifications, foreign_key: "decidim_user_id", class_name: "Decidim::Notification", dependent: :destroy
    has_many :access_grants, class_name: "Doorkeeper::AccessGrant", foreign_key: :resource_owner_id, dependent: :destroy
    has_many :access_tokens, class_name: "Doorkeeper::AccessToken", foreign_key: :resource_owner_id, dependent: :destroy
    has_many :following_follows, foreign_key: "decidim_user_id", class_name: "Decidim::Follow", dependent: :destroy

    validates :name, presence: true, unless: -> { deleted? }
    validates :nickname, presence: true, unless: -> { deleted? || managed? || name.blank? }, length: { maximum: Decidim::User.nickname_max_length }
    validates :locale, inclusion: { in: :available_locales }, allow_blank: true
    validates :tos_agreement, acceptance: true, allow_nil: false, on: :create
    validates :tos_agreement, acceptance: true, if: :user_invited?
    validates :avatar, file_size: { less_than_or_equal_to: ->(_record) { Decidim.maximum_avatar_size } }
    validates :email, :nickname, uniqueness: { scope: :organization }, unless: -> { deleted? || managed? || nickname.blank? }

    validate :all_roles_are_valid

    mount_uploader :avatar, Decidim::AvatarUploader

    scope :not_deleted, -> { where(deleted_at: nil) }

    scope :managed, -> { where(managed: true) }
    scope :not_managed, -> { where(managed: false) }

    scope :officialized, -> { where.not(officialized_at: nil) }
    scope :not_officialized, -> { where(officialized_at: nil) }

    scope :confirmed, -> { where.not(confirmed_at: nil) }
    scope :not_confirmed, -> { where(confirmed_at: nil) }

    attr_accessor :newsletter_notifications

    searchable_fields({
                        # scope_id: :decidim_scope_id,
                        organization_id: :decidim_organization_id,
                        A: :name,
                        datetime: :created_at
                      },
                      index_on_create: ->(user) { !user.deleted? },
                      index_on_update: ->(user) { !user.deleted? })

    def user_invited?
      invitation_token_changed? && invitation_accepted_at_changed?
    end

    # Public: Allows customizing the invitation instruction email content when
    # inviting a user.
    #
    # Returns a String.
    attr_accessor :invitation_instructions

    def self.log_presenter_class_for(_log)
      Decidim::AdminLog::UserPresenter
    end

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

    # Public: whether the user has been officialized or not
    def officialized?
      !officialized_at.nil?
    end

    def follows?(followable)
      Decidim::Follow.where(user: self, followable: followable).any?
    end

    # Public: Returns a collection with all the entities this user is following.
    #
    # This can't be done as with a `has_many :following, through: :following_follows`
    # since it's a polymorphic relation and Rails doesn't know how to load it. With
    # this implementation we only query the database once for each kind of following.
    #
    # Returns an Array of Decidim::Followable
    def following
      @following ||= begin
                       followings = following_follows.pluck(:decidim_followable_type, :decidim_followable_id)
                       grouped_followings = followings.each_with_object({}) do |(type, following_id), all|
                         all[type] ||= []
                         all[type] << following_id
                         all
                       end

                       grouped_followings.flat_map do |type, ids|
                         type.constantize.where(id: ids)
                       end
                     end
    end

    def following_users
      @following_users ||= following.select do |f|
        f.is_a?(Decidim::User)
      end
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

    def self.user_collection(user)
      where(id: user.id)
    end

    def self.export_serializer
      Decidim::DataPortabilitySerializers::DataPortabilityUserSerializer
    end

    def self.data_portability_images(user)
      user_collection(user).map(&:avatar)
    end

    def tos_accepted?
      return true if managed || organization.tos_version.nil?
      return false if accepted_tos_version.nil?
      accepted_tos_version >= organization.tos_version
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
