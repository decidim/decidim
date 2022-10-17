# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # A form object used to copy a meeting from the admin
      # dashboard.
      #
      class MeetingCopyForm < ::Decidim::Meetings::Admin::MeetingForm

        attribute :show_embedded_iframe, Boolean, default: false

        mimic :meeting
        def map_model(model)
          self.services = model.services.map do |service|
            MeetingServiceForm.new(service.attributes)
          end
        end

        def questionnaire
          Decidim::Forms::Questionnaire.new
        end
      end
    end
  end
end
