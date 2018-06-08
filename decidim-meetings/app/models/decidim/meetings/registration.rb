# frozen_string_literal: true

module Decidim
  module Meetings
    # The data store for a Registration in the Decidim::Meetings component.
    class Registration < Meetings::ApplicationRecord
      include Decidim::DataPortability

      belongs_to :meeting, foreign_key: "decidim_meeting_id", class_name: "Decidim::Meetings::Meeting"
      belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::User"

      validates :user, uniqueness: { scope: :meeting }

      def self.user_collection(user)
        where(decidim_user_id: user.id)
      end

      def self.export_serializer
        Decidim::Meetings::DataPortabilityRegistrationSerializer
      end
    end
  end
end
