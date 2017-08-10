# frozen_string_literal: true

module Decidim
  module Meetings
    # The data store for a Inscription in the Decidim::Meetings component.
    class Inscription < Meetings::ApplicationRecord
      belongs_to :meeting, foreign_key: "decidim_meeting_id", class_name: "Decidim::Meetings::Meeting"
      belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::User"
    end
  end
end
