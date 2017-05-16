# frozen_string_literal: true

module Decidim
  # A UserGroup is an organization of citizens
  class UserGroup < ApplicationRecord
    has_many :users, through: :memberships, class_name: "Decidim::User", foreign_key: :decidim_user_id
    has_many :memberships, class_name: "Decidim::UserGroupMembership", foreign_key: :decidim_user_group_id

    validates :name, presence: true
    validates :document_number, presence: true
    validates :phone, presence: true
    validates :avatar, file_size: { less_than_or_equal_to: 5.megabytes }
    mount_uploader :avatar, Decidim::AvatarUploader

    scope :verified, -> { where.not(verified_at: nil) }

    # Public: Mark the user group as verified
    def verify!
      update_attribute(:verified_at, Time.current)
    end

    # Public: Checks if the user group is verified.
    def verified?
      verified_at.present?
    end
  end
end
