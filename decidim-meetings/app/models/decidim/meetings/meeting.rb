# frozen_string_literal: true
module Decidim
  module Meetings
    # The data store for a Meeting in the Decidim::Meetings component. It stores a
    # title, description and any other useful information to render a custom meeting.
    class Meeting < Meetings::ApplicationRecord
      belongs_to :feature, foreign_key: "decidim_feature_id", class_name: Decidim::Feature

      validates :title, presence: true
    end
  end
end
