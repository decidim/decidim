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
    REGEXP_NICKNAME = /\A[\w-]+\z/

    has_one_attached :avatar
    validates_avatar :avatar, uploader: Decidim::AvatarUploader

    validates :name, format: { with: REGEXP_NAME }
    validates :nickname,
              presence: true,
              format: { with: REGEXP_NICKNAME },
              length: { maximum: Decidim::UserBaseEntity.nickname_max_length },
              if: -> { validate_nickname_and_email? }
    validates :nickname, uniqueness: { scope: :organization }, if: -> { validate_nickname_and_email? && nickname.present? }
    validates :email, uniqueness: { scope: :organization }, if: -> { validate_nickname_and_email? && email.present? }

    scope :confirmed, -> { where.not(confirmed_at: nil) }
    scope :not_confirmed, -> { where(confirmed_at: nil) }

    # Visible user entities (users or groups) are those that should appear
    # publicly on the platform, such as on their personal profile page, the
    # GraphQL API or other places where the user may appear.
    scope :visible, lambda {
      profile_published.not_blocked.merge(
        Decidim::User.tos_accepted.or(Decidim::UserGroup.verified)
      )
    }

    # User entities (user groups) that have their profile visible on the
    # platform from the user's own perspective. This includes also blocked users
    # because the decision to hide their profile has been made by someone else.
    scope :profile_published, -> { confirmed.where(deleted_at: nil, managed: false) }

    scope :blocked, -> { where(blocked: true) }
    scope :not_blocked, -> { where(blocked: false) }
    scope :available, -> { where(deleted_at: nil, blocked: false, managed: false) }

    def validate_nickname_and_email?
      return false if managed?
      return false if deleted_at.present?

      true
    end

    def visible?
      return false if blocked?

      profile_published?
    end

    # Note that the blocked users have the profile published on purpose for the
    # admin users to be able access those profiles e.g. for inspecting the
    # user's activity on the platform.
    def profile_published?
      return false if managed?
      return false if deleted_at.present?

      confirmed_at.present?
    end

    # This will hide the resource from the search index when the resource is not
    # public and when the resource is searchable (i.e. `Decidim::User`).
    def hidden?
      !visible?
    end

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
