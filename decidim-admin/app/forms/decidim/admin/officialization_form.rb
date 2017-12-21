# frozen_string_literal: true

module Decidim
  module Admin
    # A form object used to officialize users from the admin dashboard.
    class OfficializationForm < Form
      include TranslatableAttributes

      translatable_attribute :officialized_as, String

      attribute :user_id, Integer

      validates :officialized_as, length: { maximum: 300 }

      validates :user, presence: true, if: ->(form) { form.user_id.present? }

      def map_model(user)
        self.officialized_as = user.officialized_as
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
