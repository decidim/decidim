# frozen_string_literal: true

module Decidim
  module Admin
    # A form object used to officialize users from the admin dashboard.
    class BlockUserForm < Form
      attribute :user_id, Integer
      attribute :justification, String

      validates :user, presence: true
      validates :justification, presence: true, length: { minimum: UserBlock::MINIMUM_JUSTIFICATION_LENGTH }

      def map_model(user)
        self.user_id = user.id
      end

      def user
        @user ||= Decidim::User.find_by(
          id: user_id,
          organization: current_organization
        )
      end
    end
  end
end
