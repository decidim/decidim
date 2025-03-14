# frozen_string_literal: true

module Decidim
  module Admin
    # A form object used to block users on the admin dashboard.
    class BlockUserForm < Form
      attribute :user_id, Integer
      attribute :justification, String
      attribute :hide, Boolean, default: false

      validates :user, presence: true
      validates :justification, presence: true, length: { minimum: UserBlock::MINIMUM_JUSTIFICATION_LENGTH }

      def map_model(user)
        self.user_id = user.id
      end

      def user
        @user ||= Decidim::UserBaseEntity.find_by(
          id: user_id,
          organization: current_organization
        )
      end
    end
  end
end
