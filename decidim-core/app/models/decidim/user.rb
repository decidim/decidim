# frozen_string_literal: true

require "devise/models/decidim_validatable"
require "devise/models/decidim_newsletterable"
require "valid_email2"

module Decidim
  # A User is a participant that wants to join the platform to engage.
  class User < UserBaseEntity
    include Decidim::DownloadYourData
    include Decidim::Searchable
    include Decidim::ActsAsAuthor
    include Decidim::UserReportable
    include Decidim::Traceable

    REGEXP_NICKNAME = /\A[\w\-]+\z/

    class Roles
      def self.all
        Decidim.config.user_roles
      end
    end

    devise :invitable, :database_authenticatable, :registerable, :confirmable, :timeoutable,
           :recoverable, :trackable, :lockable,
           :decidim_validatable, :decidim_newsletterable,
           :omniauthable, omniauth_providers: Decidim::OmniauthProvider.available.keys,
                          request_keys: [:env], reset_password_keys: [:decidim_organization_id, :email],
                          confirmation_keys: [:decidim_organization_id, :email]
    devise :rememberable if Decidim.enable_remember_me

    has_many :identities, foreign_key: "decidim_user_id", class_name: "Decidim::Identity", dependent: :destroy
    has_many :memberships, class_name: "Decidim::UserGroupMembership", foreign_key: :decidim_user_id, dependent: :destroy
    has_many :user_groups, through: :memberships, class_name: "Decidim::UserGroup", foreign_key: :decidim_user_group_id
    has_many :access_grants, class_name: "Doorkeeper::AccessGrant", foreign_key: :resource_owner_id, dependent: :destroy
    has_many :access_tokens, class_name: "Doorkeeper::AccessToken", foreign_key: :resource_owner_id, dependent: :destroy
    has_many :reminders, foreign_key: "decidim_user_id", class_name: "Decidim::Reminder", dependent: :destroy

    has_one :blocking, class_name: "Decidim::UserBlock", foreign_key: :id, primary_key: :block_id, dependent: :destroy

    validates :name, presence: true, unless: -> { deleted? }
    validates :nickname,
              presence: true,
              format: { with: REGEXP_NICKNAME },
              length: { maximum: Decidim::User.nickname_max_length },
              unless: -> { deleted? || managed? }
    validates :locale, inclusion: { in: :available_locales }, allow_blank: true
    validates :tos_agreement, acceptance: true, allow_nil: false, on: :create
    validates :tos_agreement, acceptance: true, if: :user_invited?
    validates :email, :nickname, uniqueness: { scope: :organization }, unless: -> { deleted? || managed? || nickname.blank? }

    validate :all_roles_are_valid

    has_one_attached :download_your_data_file

    scope :not_deleted, -> { where(deleted_at: nil) }

    scope :managed, -> { where(managed: true) }
    scope :not_managed, -> { where(managed: false) }

    scope :officialized, -> { where.not(officialized_at: nil) }
    scope :not_officialized, -> { where(officialized_at: nil) }

    scope :interested_in_scopes, lambda { |scope_ids|
      actual_ids = scope_ids.select(&:presence)
      if actual_ids.count.positive?
        ids = actual_ids.map(&:to_i).join(",")
        where(Arel.sql("extended_data->'interested_scopes' @> ANY('{#{ids}}')").to_s)
      else
        # Do not apply the scope filter when there are scope ids available. Note
        # that the active record scope must always return an active record
        # collection.
        self
      end
    }

    scope :org_admins_except_me, ->(user) { where(organization: user.organization, admin: true).where.not(id: user.id) }

    attr_accessor :newsletter_notifications

    searchable_fields({
                        # scope_id: :decidim_scope_id,
                        organization_id: :decidim_organization_id,
                        A: :name,
                        B: :nickname,
                        datetime: :created_at
                      },
                      index_on_create: ->(user) { !(user.deleted? || user.blocked?) },
                      index_on_update: ->(user) { !(user.deleted? || user.blocked?) })

    before_save :ensure_encrypted_password
    before_save :save_password_change, if: -> { needs_to_save_password_change? }

    def user_invited?
      invitation_token_changed? && invitation_accepted_at_changed?
    end

    def needs_to_save_password_change?
      admin? && encrypted_password_changed? && Decidim.config.admin_password_strong_enable
    end

    # Public: Allows customizing the invitation instruction email content when
    # inviting a user.
    #
    # Returns a String.
    attr_accessor :invitation_instructions

    def invitation_pending?
      invited_to_sign_up? && !invitation_accepted?
    end

    # Returns the user corresponding to the given +email+ if it exists and has pending invitations,
    #   otherwise returns nil.
    def self.has_pending_invitations?(organization_id, email)
      invitation_not_accepted.find_by(decidim_organization_id: organization_id, email: email)
    end

    # Returns the presenter for this author, to be used in the views.
    # Required by ActsAsAuthor.
    def presenter
      Decidim::UserPresenter.new(self)
    end

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

    # Public: whether the user accepts direct messages from another
    def accepts_conversation?(user)
      return follows?(user) if direct_message_types == "followed-only"

      true
    end

    def unread_conversations
      Decidim::Messaging::Conversation.unread_by(self)
    end

    def unread_messages_count
      @unread_messages_count ||= Decidim::Messaging::Receipt.unread_count(self)
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
        email: warden_conditions[:email].to_s.downcase,
        decidim_organization_id: organization.id
      )
    end

    def self.user_collection(user)
      where(id: user.id)
    end

    def self.export_serializer
      Decidim::DownloadYourDataSerializers::DownloadYourDataUserSerializer
    end

    def self.download_your_data_images(user)
      user_collection(user).map(&:avatar)
    end

    def tos_accepted?
      return true if managed
      return false if accepted_tos_version.nil?

      # For some reason, if we don't use `#to_i` here we get some
      # cases where the comparison returns false, but calling `#to_i` returns
      # the same number :/
      accepted_tos_version.to_i >= organization.tos_version.to_i
    end

    def admin_terms_accepted?
      return true if admin_terms_accepted_at
    end

    # Whether this user can be verified against some authorization or not.
    def verifiable?
      confirmed? || managed? || being_impersonated?
    end

    def being_impersonated?
      ImpersonationLog.active.exists?(user: self)
    end

    def interested_scopes_ids
      extended_data["interested_scopes"] || []
    end

    def interested_scopes
      @interested_scopes ||= organization.scopes.where(id: interested_scopes_ids)
    end

    def user_name
      extended_data["user_name"] || name
    end

    # return the groups where this user has been accepted
    def accepted_user_groups
      UserGroups::AcceptedUserGroups.for(self)
    end

    # return the groups where this user has admin permissions
    def manageable_user_groups
      UserGroups::ManageableUserGroups.for(self)
    end

    def authenticatable_salt
      "#{super}#{session_token}"
    end

    def invalidate_all_sessions!
      self.session_token = SecureRandom.hex
      save!
    end

    ransacker :invitation_accepted_at do
      Arel.sql(%{("decidim_users"."invitation_accepted_at")::text})
    end

    ransacker :last_sign_in_at do
      Arel.sql(%{("decidim_users"."last_sign_in_at")::text})
    end

    def notifications_subscriptions
      notification_settings.fetch("subscriptions", {})
    end

    def needs_password_update?
      return false unless admin?
      return false unless Decidim.config.admin_password_strong_enable
      return true if password_updated_at.blank?

      password_updated_at < Decidim.config.admin_password_days_expiration.days.ago
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

    def after_confirmation
      return unless organization.send_welcome_notification?

      Decidim::EventsManager.publish(
        event: "decidim.events.core.welcome_notification",
        event_class: WelcomeNotificationEvent,
        resource: self,
        affected_users: [self]
      )
    end

    private

    # Changes default Devise behaviour to use ActiveJob to send async emails.
    def send_devise_notification(notification, *args)
      devise_mailer.send(notification, self, *args).deliver_later
    end

    def all_roles_are_valid
      errors.add(:roles, :invalid) unless roles.compact.all? { |role| Roles.all.include?(role) }
    end

    def available_locales
      Decidim.available_locales.map(&:to_s)
    end

    def ensure_encrypted_password
      restore_encrypted_password! if will_save_change_to_encrypted_password? && encrypted_password.blank?
    end

    def save_password_change
      return unless persisted?

      # We don't want to run validations here because that could lead to an endless validation loop.
      # rubocop:disable Rails/SkipsModelValidations
      update_column(:password_updated_at, Time.current)
      update_column(:previous_passwords, [encrypted_password_was, *previous_passwords].first(Decidim.config.admin_password_repetition_times))
      # rubocop:enable Rails/SkipsModelValidations
    end
  end
end
