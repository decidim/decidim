# frozen_string_literal: true

module Decidim
  # This class serves as a base class for `Decidim::User` and `Decidim::UserGroup`
  # so that we can set some shared logic.
  # This class is not supposed to be used directly.
  class UserBaseEntity < ApplicationRecord
    self.table_name = "decidim_users"

    include Nicknamizable
    include Resourceable
    include Decidim::Followable
    include Decidim::Loggable
    include Decidim::HasUploadValidations

    belongs_to :organization, foreign_key: "decidim_organization_id", class_name: "Decidim::Organization"
    has_many :notifications, foreign_key: "decidim_user_id", class_name: "Decidim::Notification", dependent: :destroy
    has_many :following_follows, foreign_key: "decidim_user_id", class_name: "Decidim::Follow", dependent: :destroy

    has_one :blocking, class_name: "Decidim::UserBlock", foreign_key: :id, primary_key: :block_id, dependent: :destroy

    # Regex for name & nickname format validations
    REGEXP_NAME = /\A(?!.*[<>?%&\^*#@()\[\]=+:;"{}\\|])/

    has_one_attached :avatar
    validates_avatar :avatar, uploader: Decidim::AvatarUploader

    validates :name, format: { with: REGEXP_NAME }

    scope :confirmed, -> { where.not(confirmed_at: nil) }
    scope :not_confirmed, -> { where(confirmed_at: nil) }

    scope :blocked, -> { where(blocked: true) }
    scope :not_blocked, -> { where(blocked: false) }
    scope :available, -> { where(deleted_at: nil, blocked: false, managed: false) }

    # Public: Returns a collection with all the public entities this user is following.
    #
    # This cannot be done as with a `has_many :following, through: :following_follows`
    # since it is a polymorphic relation and Rails does not know how to load it. With
    # this implementation we only query the database once for each kind of following.
    #
    # Returns an Array of Decidim::Followable
    def public_followings
      @public_followings ||= following_follows.select("array_agg(decidim_followable_id)")
                                              .group(:decidim_followable_type)
                                              .pluck(:decidim_followable_type, "array_agg(decidim_followable_id)")
                                              .to_h
                                              .flat_map do |type, ids|
        only_public(type.constantize, ids)
      end
    end

    def public_users_followings
      # To include users and groups self.class is not valid because for a user
      # self.class.joins(:follows)... only return users
      @public_users_followings ||= users_followings.not_blocked
    end

    def users_followings
      @users_followings ||= Decidim::UserBaseEntity.joins(:follows).where(decidim_follows: { user: self })
    end

    def followings_blocked?
      Decidim::UserBaseEntity.joins(:follows).where(decidim_follows: { user: self }).blocked.exists?
    end

    def self.ransackable_attributes(_auth_object = nil)
      # %w(about accepted_tos_version admin admin_terms_accepted_at avatar block_id blocked blocked_at
      #    confirmation_sent_at confirmed_at created_at current_sign_in_at current_sign_in_ip decidim_organization_id
      #    delete_reason deleted_at digest_sent_at direct_message_types email email_on_moderations extended_data
      #    failed_attempts followers_count following_count follows_count id invitation_accepted_at invitation_created_at
      #    invitation_limit invitation_sent_at invitations_count invited_by_id invited_by_type last_sign_in_at last_sign_in_ip
      #    locale locked_at managed name newsletter_notifications_at nickname notification_settings notification_types
      #    notifications_sending_frequency officialized_as officialized_at password_updated_at personal_url previous_passwords
      #    remember_created_at reset_password_sent_at roles sign_in_count type unconfirmed_email updated_at)
      base = %w()

      return base unless _auth_object&.admin?

      base + %w()
    end

    def self.ransackable_associations(_auth_object = nil)
      # %w(access_grants access_tokens avatar_attachment avatar_blob blocking download_your_data_file_attachment download_your_data_file_blob followers
      #    following_follows follows identities invited_by memberships notifications organization reminders resource_links_from resource_links_to
      #    resource_permission searchable_resources user_groups user_moderation user_reports versions)
      []
    end

    private

    def only_public(klass, ids)
      scope = klass.where(id: ids)
      scope = scope.public_spaces if klass.try(:participatory_space?)
      scope = scope.includes(:component) if klass.try(:has_component?)
      scope = scope.filter(&:visible?) if klass.method_defined?(:visible?)
      scope = scope.reject(&:blocked) if klass == Decidim::UserBaseEntity
      scope
    end
  end
end
