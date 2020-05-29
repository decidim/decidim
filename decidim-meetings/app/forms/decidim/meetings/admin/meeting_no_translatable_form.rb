# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This class holds a Form to update non translatable meetings from Decidim's admin panel.
      class MeetingNoTranslatableForm < MeetingBaseForm
        attribute :title, String
        attribute :description, String
        attribute :location, String
        attribute :location_hints, String

        validates :title, presence: true
        validates :description, presence: true
        validates :location, presence: true
      end
    end
  end
end
