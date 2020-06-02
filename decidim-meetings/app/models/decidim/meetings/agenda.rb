# frozen_string_literal: true

module Decidim
  module Meetings
    # The data store for a Agena in the Decidim::Meetings component. It stores a
    # title, and visible field to render inside a meeting.
    class Agenda < Meetings::ApplicationRecord
      include Decidim::Traceable
      include Decidim::Loggable
      include Decidim::TranslatableResource

      translatable_fields :title

      belongs_to :meeting, foreign_key: "decidim_meeting_id", class_name: "Decidim::Meetings::Meeting"
      has_many :agenda_items, foreign_key: "decidim_agenda_id", class_name: "Decidim::Meetings::AgendaItem", dependent: :destroy, inverse_of: :agenda

      def self.log_presenter_class_for(_log)
        Decidim::Meetings::AdminLog::AgendaPresenter
      end
    end
  end
end
