# frozen_string_literal: true

module Decidim
  module Conferences
    # The data store for an Invite in the Decidim::Conferences component.
    class ConferenceInvite < ApplicationRecord
      include Decidim::Traceable
      include Decidim::Loggable
      include Decidim::DownloadYourData

      belongs_to :conference, foreign_key: "decidim_conference_id", class_name: "Decidim::Conference"
      belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::User"
      belongs_to :registration_type, foreign_key: "decidim_conference_registration_type_id", class_name: "Decidim::Conferences::RegistrationType"

      validates :user, uniqueness: { scope: :conference }

      def self.export_serializer
        Decidim::Conferences::DownloadYourDataConferenceInviteSerializer
      end

      def self.log_presenter_class_for(_log)
        Decidim::Conferences::AdminLog::InvitePresenter
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
