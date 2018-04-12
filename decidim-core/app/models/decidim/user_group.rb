# frozen_string_literal: true

module Decidim
  # A UserGroup is an organization of citizens
  class UserGroup < ApplicationRecord
    include Decidim::Traceable
    include Decidim::Loggable

    belongs_to :organization, foreign_key: "decidim_organization_id", class_name: "Decidim::Organization"

    has_many :memberships, class_name: "Decidim::UserGroupMembership", foreign_key: :decidim_user_group_id, dependent: :destroy
    has_many :users, through: :memberships, class_name: "Decidim::User", foreign_key: :decidim_user_id

    validates :name, presence: true, uniqueness: { scope: :decidim_organization_id }
    validates :document_number, presence: true, uniqueness: { scope: :decidim_organization_id }
    validates :phone, presence: true
    validates :avatar, file_size: { less_than_or_equal_to: ->(_record) { Decidim.maximum_avatar_size } }

    validate :correct_state

    mount_uploader :avatar, Decidim::AvatarUploader

    scope :verified, -> { where.not(verified_at: nil) }
    scope :rejected, -> { where.not(rejected_at: nil) }

    def self.log_presenter_class_for(_log)
      Decidim::AdminLog::UserGroupPresenter
    end

    # Public: Checks if the user group is verified.
    def verified?
      verified_at.present?
    end

    # Public: Checks if the user group is rejected.
    def rejected?
      rejected_at.present?
    end

    # Public: Checks if the user group is pending.
    def pending?
      verified_at.blank? && rejected_at.blank?
    end

    def self.get_unique_random_user_group_document_number(current_organization)
      random_range = 99999
      user_group_document_number = SecureRandom.random_number(random_range)
      # While our random number is already picked, we picked an other one
      while UserGroup.where(
              document_number: user_group_document_number,
              decidim_organization_id: current_organization.id
              ).first.present?
        user_group_document_number = SecureRandom.random_number(random_range)
      end
      return user_group_document_number
    end

    private

    # Private: Checks if the state user group is correct.
    def correct_state
      errors.add(:base, :invalid) if verified? && rejected?
    end
  end
end
