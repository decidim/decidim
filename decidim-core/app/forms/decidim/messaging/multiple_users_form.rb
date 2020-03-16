# frozen_string_literal: true

module Decidim
  module Messaging
    class MultipleUsersForm < Decidim::Form
      mimic :conversation

      attribute :recipient_ids, Array

      validates :recipients, presence: true

      def recipients
byebug
        @recipients ||= Decidim::User
                       .where.not(id: current_user.id)
                       .where(organization: current_user.organization)
                       .where(id: recipient_ids)
byebug
      end
    end
  end
end
