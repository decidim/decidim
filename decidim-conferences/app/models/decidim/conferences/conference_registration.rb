# frozen_string_literal: true

module Decidim
  module Conferences
    # The data store for a Registration in the Decidim::Conferences component.
    class ConferenceRegistration < ApplicationRecord
      include Decidim::DownloadYourData

      belongs_to :conference, foreign_key: "decidim_conference_id", class_name: "Decidim::Conference"
      belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::User"
      belongs_to :registration_type, foreign_key: "decidim_conference_registration_type_id", class_name: "Decidim::Conferences::RegistrationType"

      validates :user, uniqueness: { scope: :conference }

      scope :confirmed, -> { where.not(confirmed_at: nil) }

      def self.user_collection(user)
        where(decidim_user_id: user.id)
      end

      def self.export_serializer
        Decidim::Conferences::DownloadYourDataConferenceRegistrationSerializer
      end

      def confirmed?
        confirmed_at.present?
      end

      def self.log_presenter_class_for(_log)
        Decidim::Conferences::AdminLog::ConferenceRegistrationPresenter
      end
    end
  end
end
