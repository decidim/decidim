# frozen_string_literal: true
module Decidim
  module Meetings
    # The data store for a Meeting in the Decidim::Meetings component. It stores a
    # title, description and any other useful information to render a custom meeting.
    class Meeting < Meetings::ApplicationRecord
      validates :title, presence: true
      belongs_to :component, foreign_key: "decidim_component_id", class_name: Decidim::Component
    end
  end
end
