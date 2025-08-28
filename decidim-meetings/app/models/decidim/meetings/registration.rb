# frozen_string_literal: true

module Decidim
  module Meetings
    # The data store for a Registration in the Decidim::Meetings component.
    class Registration < Meetings::ApplicationRecord
      include Decidim::DownloadYourData

      belongs_to :meeting, foreign_key: "decidim_meeting_id", class_name: "Decidim::Meetings::Meeting"
      belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::User"

      validates :user, uniqueness: { scope: :meeting }
      validates :code, uniqueness: { allow_blank: true, scope: :meeting }
      validates :code, presence: true, on: :create

      before_validation :generate_code, on: :create

      enum :status, { registered: "registered", waiting_list: "waiting_list" }

      scope :on_waiting_list, -> { waiting_list.order(:created_at) }
      scope :public_participant, -> { where(public_participation: true) }

      delegate :component, :organization, to: :meeting

      def self.user_collection(user)
        where(decidim_user_id: user.id)
      end

      def self.export_serializer
        Decidim::Meetings::DownloadYourDataRegistrationSerializer
      end

      # Public: Checks if the registration has been validated.
      #
      # Returns Boolean.
      def validated?
        validated_at?
      end

      def presenter
        Decidim::Meetings::RegistrationPresenter.new(self)
      end

      def validation_code_short_link
        Decidim::ShortLink.to(
          self,
          meeting.component.mounted_admin_engine,
          route_name: :qr_mark_as_attendee_meeting_registrations_attendee,
          params: { meeting_id: meeting.id, id: code }
        )
      end

      private

      def generate_code
        self[:code] ||= calculate_registration_code
      end

      # Calculates a unique code for the model using the class
      # provided by the configuration and scoped to the meeting.
      #
      # Returns a String.
      def calculate_registration_code
        Decidim::Meetings::Registrations.code_generator.generate(self)
      end
    end
  end
end
