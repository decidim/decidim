# frozen_string_literal: true

module Decidim
  module ParticipatorySpace
    # This class gives a given User access to a given private Member
    class Member < ApplicationRecord
      include Decidim::DownloadYourData
      include ParticipatorySpaceUser
      include Decidim::TranslatableResource

      belongs_to :participatory_space, polymorphic: true

      translatable_fields :role

      delegate :email, :name, to: :user

      scope :by_participatory_space, ->(participatory_space) { where(participatory_space_id: participatory_space.id, participatory_space_type: participatory_space.class.to_s) }
      scope :published, -> { where(published: true) }

      def self.user_collection(user)
        where(decidim_user_id: user.id)
      end

      def self.member_ids_for_participatory_spaces(spaces)
        joins(:user).where(participatory_space: spaces).distinct.pluck(:decidim_user_id)
      end

      def self.export_serializer
        Decidim::DownloadYourDataSerializers::DownloadYourDataMemberSerializer
      end

      def self.log_presenter_class_for(_log)
        Decidim::AdminLog::ParticipatorySpace::MemberPresenter
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

      def target_space_association = :participatory_space
    end
  end
end
