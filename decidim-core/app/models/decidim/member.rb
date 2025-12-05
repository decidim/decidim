# frozen_string_literal: true

module Decidim
  # This class gives a given User access to a given private ParticipatorySpacePrivateUser
  class ParticipatorySpacePrivateUser < ApplicationRecord
    include Decidim::DownloadYourData
    include ParticipatorySpaceUser
    include Decidim::TranslatableResource

    belongs_to :privatable_to, polymorphic: true

    translatable_fields :role

    delegate :email, :name, to: :user

    scope :by_participatory_space, ->(privatable_to) { where(privatable_to_id: privatable_to.id, privatable_to_type: privatable_to.class.to_s) }
    scope :published, -> { where(published: true) }

    def self.user_collection(user)
      where(decidim_user_id: user.id)
    end

    def self.private_user_ids_for_participatory_spaces(spaces)
      joins(:user).where(privatable_to: spaces).distinct.pluck(:decidim_user_id)
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

    def self.ransackable_attributes(auth_object = nil)
      return [] unless auth_object&.admin?

      %w(name nickname email invitation_accepted_at last_sign_in_at invitation_sent_at role)
    end

    def self.ransackable_associations(_auth_object = nil)
      %w(user)
    end

    def target_space_association = :privatable_to
  end
end
