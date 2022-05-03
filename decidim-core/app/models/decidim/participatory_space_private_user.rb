# frozen_string_literal: true

module Decidim
  # This class gives a given User access to a given private ParticipatorySpacePrivateUser
  class ParticipatorySpacePrivateUser < ApplicationRecord
    include Decidim::DownloadYourData

    belongs_to :user, class_name: "Decidim::User", foreign_key: :decidim_user_id
    belongs_to :privatable_to, polymorphic: true

    validate :user_and_participatory_space_same_organization

    scope :by_participatory_space, ->(privatable_to) { where(privatable_to_id: privatable_to.id, privatable_to_type: privatable_to.class.to_s) }

    def self.user_collection(user)
      where(decidim_user_id: user.id)
    end

    def self.export_serializer
      Decidim::DownloadYourDataSerializers::DownloadYourDataParticipatorySpacePrivateUserSerializer
    end

    def self.log_presenter_class_for(_log)
      Decidim::AdminLog::ParticipatorySpacePrivateUserPresenter
    end

    ransacker :name do
      Arel.sql(%{("decidim_users"."name")::text})
    end

    ransacker :email do
      Arel.sql(%{("decidim_users"."email")::text})
    end

    ransacker :invitation_sent_at do
      Arel.sql(%{("invitation_sent_at")::text})
    end

    ransacker :invitation_accepted_at do
      Arel.sql(%{("invitation_accepted_at")::text})
    end

    private

    # Private: check if the participatory space and the user have the same organization
    def user_and_participatory_space_same_organization
      return if !privatable_to || !user

      errors.add(:privatable_to, :invalid) unless user.organization == privatable_to.organization
    end
  end
end
