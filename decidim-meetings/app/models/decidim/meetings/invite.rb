# frozen_string_literal: true

module Decidim
  module Meetings
    # The data store for an Invite in the Decidim::Meetings component.
    class Invite < Meetings::ApplicationRecord
      include Decidim::Traceable
      include Decidim::Loggable
      include Decidim::DownloadYourData

      belongs_to :meeting, foreign_key: "decidim_meeting_id", class_name: "Decidim::Meetings::Meeting"
      belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::User"

      validates :user, uniqueness: { scope: :meeting }

      def self.export_serializer
        Decidim::Meetings::DownloadYourDataInviteSerializer
      end

      def self.log_presenter_class_for(_log)
        Decidim::Meetings::AdminLog::InvitePresenter
      end

      def self.user_collection(user)
        where(decidim_user_id: user.id)
      end

      def accept!
        update!(accepted_at: Time.current, rejected_at: nil)
      end

      def reject!
        update!(rejected_at: Time.current, accepted_at: nil)
      end
      alias decline! reject!
    end
  end
end
