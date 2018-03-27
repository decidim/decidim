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
        translatable_attribute :conciliation_service_description, String
        translatable_attribute :simultaneous_languages, String

        attribute :address, String
        attribute :latitude, Float
        attribute :longitude, Float
        attribute :start_time, Decidim::Attributes::TimeWithZone
        attribute :end_time, Decidim::Attributes::TimeWithZone
        attribute :has_conciliation_service, Boolean
        attribute :has_space_adapted_for_functional_diversity, Boolean
        attribute :has_simultaneous_translations, Boolean

        mimic :meeting

        validates :current_component, presence: true

        validates :title, translatable_presence: true
        validates :description, translatable_presence: true
        validates :location, translatable_presence: true
        validates :address, presence: true
        validates :address, geocoding: true, if: -> { Decidim.geocoder.present? }
        validates :start_time, presence: true, date: { before: :end_time }
        validates :end_time, presence: true, date: { after: :start_time }
        validates :conciliation_service_description, translatable_presence: true, if: ->(form) { form.has_conciliation_service? }
        validates :simultaneous_languages, translatable_presence: true, if: ->(form) { form.has_simultaneous_translations? }

        alias component current_component
      end
    end
  end
end
