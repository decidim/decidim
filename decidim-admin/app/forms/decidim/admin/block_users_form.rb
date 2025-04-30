# frozen_string_literal: true

module Decidim
  module Admin
    # A form object used to block users on the admin dashboard.
    class BlockUsersForm < Form
      attribute :user_ids, Array[Integer]
      attribute :justification, String
      attribute :hide, Boolean, default: false

      validates :justification, presence: true, length: { minimum: UserBlock::MINIMUM_JUSTIFICATION_LENGTH }

      def users
        @users ||= Decidim::UserBaseEntity.where(
          id: user_ids,
          organization: current_organization
        )
      end
    end
  end
end
