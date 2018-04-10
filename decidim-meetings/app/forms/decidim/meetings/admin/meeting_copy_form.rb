# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # A form object used to copy a meeting from the admin
      # dashboard.
      #
      class MeetingCopyForm < Form
        include TranslatableAttributes

        translatable_attribute :title, String
        translatable_attribute :description, String
        translatable_attribute :location, String
        translatable_attribute :location_hints, String
        translatable_attribute :open_type_other, String
        translatable_attribute :public_type_other, String
        translatable_attribute :transparent_type_other, String

        attribute :address, String
        attribute :latitude, Float
        attribute :longitude, Float
        attribute :start_time, Decidim::Attributes::TimeWithZone
        attribute :end_time, Decidim::Attributes::TimeWithZone
        attribute :open_type, String
        attribute :public_type, String
        attribute :transparent_type, String
        attribute :organizer_id, Integer

        mimic :meeting

        validates :current_component, presence: true

        validates :title, translatable_presence: true
        validates :description, translatable_presence: true
        validates :location, translatable_presence: true
        validates :address, presence: true
        validates :address, geocoding: true, if: -> { Decidim.geocoder.present? }
        validates :start_time, presence: true, date: { before: :end_time }
        validates :end_time, presence: true, date: { after: :start_time }
        validates :organizer, presence: true, if: ->(form) { form.organizer_id.present? }
        validates :open_type_other, translatable_presence: true, if: ->(form) { form.open_type == "other" }
        validates :public_type_other, translatable_presence: true, if: ->(form) { form.public_type == "other" }
        validates :transparent_type_other, translatable_presence: true, if: ->(form) { form.transparent_type == "other" }

        alias component current_component

        def organizer
          @organizer ||= current_organization.users.find_by(id: organizer_id)
        end
      end
    end
  end
end
