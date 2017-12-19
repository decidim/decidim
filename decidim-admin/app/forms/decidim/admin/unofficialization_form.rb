# frozen_string_literal: true

module Decidim
  module Admin
    # A form object used to unofficialize users from the admin dashboard.
    class UnofficializationForm < Form
      attribute :user_id, Integer

      validates :user, presence: true

      def user
        @user ||= Decidim::User.find_by(id: user_id, organization: current_organization)
      end
    end
  end
end
