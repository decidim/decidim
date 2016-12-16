# frozen_string_literal: true
module Decidim
  module Meetings
    module Admin
      # This class holds a Form to create/update meetings from Decidim's admin panel.
      class MeetingForm < Decidim::Form
        include TranslatableAttributes

        translatable_attribute :title, String
        translatable_attribute :short_description, String
        translatable_attribute :description, String
        translatable_attribute :location, String
        translatable_attribute :location_hints, String
        attribute :address, String
        attribute :start_date, DateTime
        attribute :end_date, DateTime

        validates :title, translatable_presence: true
        validates :short_description, translatable_presence: true
        validates :description, translatable_presence: true
        validates :location, translatable_presence: true
        validates :address, presence: true
        validates :start_date, presence: true, date: { before: :end_date }
        validates :end_date, presence: true, date: { after: :start_date }

        validates :current_user, presence: true
        validates :current_feature, presence: true
      end
    end
  end
end
