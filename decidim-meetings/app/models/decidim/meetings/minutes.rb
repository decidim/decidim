# frozen_string_literal: true

module Decidim
  module Meetings
    # The data store for a Minutes in the Decidim::Meetings component.
    class Minutes < Meetings::ApplicationRecord
      include Decidim::Traceable
      include Decidim::Loggable
      include Decidim::TranslatableResource

      translatable_fields :description

      belongs_to :meeting, foreign_key: "decidim_meeting_id", class_name: "Decidim::Meetings::Meeting"

      def self.log_presenter_class_for(_log)
        Decidim::Meetings::AdminLog::MinutesPresenter
      end

      delegate :component, to: :meeting
    end
  end
end
