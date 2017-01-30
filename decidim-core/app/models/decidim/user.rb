# frozen_string_literal: true
require_dependency "devise/models/decidim_validatable"

module Decidim
  # A User is a citizen that wants to join the platform to participate.
  class User < ApplicationRecord
    devise :invitable, :database_authenticatable, :registerable, :confirmable,
           :recoverable, :rememberable, :trackable, :decidim_validatable,
           :omniauthable, omniauth_providers: [:facebook, :twitter, :google_oauth2]

    belongs_to :organization, foreign_key: "decidim_organization_id", class_name: Decidim::Organization
    has_many :authorizations, foreign_key: "decidim_user_id", class_name: Decidim::Authorization, inverse_of: :user
    has_many :identities, foreign_key: "decidim_user_id", class_name: Decidim::Identity
    has_many :user_groups, through: :memberships, class_name: Decidim::UserGroup, foreign_key: :decidim_user_group_id
    has_many :memberships, class_name: Decidim::UserGroupMembership, foreign_key: :decidim_user_id

    ROLES = %w(admin moderator official).freeze

    validates :organization, :name, presence: true
    validates :locale, inclusion: { in: I18n.available_locales.map(&:to_s) }, allow_blank: true
    validates :tos_agreement, acceptance: true, allow_nil: false, on: :create
    validate :all_roles_are_valid
    validates :avatar, file_size: { less_than_or_equal_to: 5.megabytes }
    mount_uploader :avatar, Decidim::AvatarUploader

    # Public: Allows customizing the invitation instruction email content when
    # inviting a user.
    #
    # Returns a String.
    attr_accessor :invitation_instructions

    delegate :can?, to: :ability

    # Gets the ability instance for the given user.
    def ability
      @ability ||= Ability.new(self)
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

    def name
      super || I18n.t("decidim.anonymous_user")
    end

    private

    def all_roles_are_valid
      errors.add(:roles, :invalid) unless roles.all? { |role| ROLES.include?(role) }
    end

    # Changes default Devise behaviour to use ActiveJob to send async emails.
    def send_devise_notification(notification, *args)
      devise_mailer.send(notification, self, *args).deliver_later
    end
  end
end
