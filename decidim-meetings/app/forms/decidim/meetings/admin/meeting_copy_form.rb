# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # A form object used to copy a meeting from the admin
      # dashboard.
      #
      class MeetingCopyForm < ::Decidim::Meetings::BaseMeetingForm
        include TranslatableAttributes

        translatable_attribute :title, String
        translatable_attribute :description, String
        translatable_attribute :location, String
        translatable_attribute :location_hints, String

        attribute :show_embedded_iframe, Boolean, default: false
        attribute :private_meeting, Boolean
        attribute :transparent, Boolean
        attribute :services, Array[MeetingServiceForm]

        mimic :meeting

        validates :online_meeting_url, url: true, if: ->(form) { form.online_meeting? || form.hybrid_meeting? }
        validates :title, translatable_presence: true
        validates :description, translatable_presence: true
        validates :location, translatable_presence: true, if: ->(form) { form.in_person_meeting? || form.hybrid_meeting? }

        def map_model(model)
          self.services = model.services.map do |service|
            MeetingServiceForm.new(service.attributes)
          end
        end

        def services_to_persist
          services.reject(&:deleted)
        end

        def number_of_services
          services.size
        end

        alias component current_component

        def questionnaire
          Decidim::Forms::Questionnaire.new
        end
      end
    end
  end
end
