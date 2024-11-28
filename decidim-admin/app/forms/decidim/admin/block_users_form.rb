# frozen_string_literal: true

module Decidim
  module Admin
    # A form object used to block users or user groups on the admin dashboard.
    class BlockUsersForm < Form
      attribute :user_ids, Array[Integer]
      attribute :justification, String
      attribute :hide, Boolean, default: false

      validates :justification, presence: true, length: { minimum: UserBlock::MINIMUM_JUSTIFICATION_LENGTH }

      def forms
        @forms ||= user_ids.map do |user_id|
          BlockUserForm.from_params(user_id:, justification:, hide:).with_context(current_organization:, current_user:)
        end
      end
    end
  end
end
