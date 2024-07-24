# frozen_string_literal: true

module Decidim
  # This class gives a given User access to a given private ParticipatorySpacePrivateUser
  class ParticipatorySpacePrivateUser < ApplicationRecord
    include Decidim::DownloadYourData
    include ParticipatorySpaceUser

    belongs_to :privatable_to, polymorphic: true

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

    ransacker :invitation_sent_at do
      Arel.sql(%{("invitation_sent_at")::text})
    end
    def self.ransackable_attributes(_auth_object = nil)
      %w(created_at decidim_user_id email id invitation_accepted_at invitation_sent_at last_sign_in_at name nickname privatable_to_id
         privatable_to_type updated_at)
    end

    def self.ransackable_associations(_auth_object = nil)
      %w(privatable_to user)
    end

    def target_space_association = :privatable_to
  end
end
