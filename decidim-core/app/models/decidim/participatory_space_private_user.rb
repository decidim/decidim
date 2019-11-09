# frozen_string_literal: true

module Decidim
  # This class gives a given User access to a given private ParticipatorySpacePrivateUser
  class ParticipatorySpacePrivateUser < ApplicationRecord
    include Decidim::DataPortability

    belongs_to :user, class_name: "Decidim::User", foreign_key: :decidim_user_id
    belongs_to :privatable_to, polymorphic: true

    validate :user_and_participatory_space_same_organization

    def self.user_collection(user)
      where(decidim_user_id: user.id)
    end

    def self.export_serializer
      Decidim::DataPortabilitySerializers::DataPortabilityParticipatorySpacePrivateUserSerializer
    end

    def self.log_presenter_class_for(_log)
      Decidim::AdminLog::ParticipatorySpacePrivateUserPresenter
    end

    private

    # Private: check if the participatory space and the user have the same organization
    def user_and_participatory_space_same_organization
      return if !privatable_to || !user

      errors.add(:privatable_to, :invalid) unless user.organization == privatable_to.organization
    end
  end
end
