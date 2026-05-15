# frozen_string_literal: true

module Decidim
  module Conferences
    # It represents a registration type of the conference
    class RegistrationType < ApplicationRecord
      include Decidim::Publicable
      include Decidim::Traceable
      include Decidim::Loggable
      include Decidim::TranslatableResource

      translatable_fields :title, :description

      belongs_to :conference, foreign_key: "decidim_conference_id", class_name: "Decidim::Conference"
      has_many :conference_meeting_registration_types, dependent: :destroy
      has_many :conference_meetings, through: :conference_meeting_registration_types, class_name: "Decidim::ConferenceMeeting"
      has_many :conference_registrations, foreign_key: "decidim_conference_registration_type_id", class_name: "Decidim::Conferences::ConferenceRegistration", dependent: :destroy

      default_scope { order(weight: :asc) }

      alias participatory_space conference

      def visible?
        conference.registrations_enabled? && published?
      end

      def self.log_presenter_class_for(_log)
        Decidim::Conferences::AdminLog::RegistrationTypePresenter
      end
    end
  end
end
