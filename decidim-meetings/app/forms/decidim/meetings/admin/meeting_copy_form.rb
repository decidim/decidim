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

        attribute :address, String
        attribute :latitude, Float
        attribute :longitude, Float
        attribute :start_time, Decidim::Attributes::TimeWithZone
        attribute :end_time, Decidim::Attributes::TimeWithZone
        attribute :private_meeting, Boolean
        attribute :transparent, Boolean
        attribute :services, Array[MeetingServiceForm]

        mimic :meeting

        validates :current_component, presence: true

        validates :title, translatable_presence: true
        validates :description, translatable_presence: true
        validates :location, translatable_presence: true
        validates :address, presence: true
        validates :address, geocoding: true, if: -> { Decidim.geocoder.present? }
        validates :start_time, presence: true, date: { before: :end_time }
        validates :end_time, presence: true, date: { after: :start_time }
        validates :organizer, presence: true

        def map_model(model)
          self.services = model.services.map do |service|
            MeetingServiceForm.new(service)
          end
        end

        def services_to_persist
          services.reject(&:deleted)
        end

        def number_of_services
          services.size
        end

        alias component current_component

        def organizer
          @organizer ||= current_organization
        end

        def questionnaire
          Decidim::Forms::Questionnaire.new
        end
      end
    end
  end
end
