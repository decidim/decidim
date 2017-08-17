# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This class holds a Form to update meeting registrations from Decidim's admin panel.
      class MeetingRegistrationsForm < Decidim::Form
        include TranslatableAttributes

        mimic :meeting

        attribute :registrations_enabled, Boolean
        attribute :available_slots, Integer
        translatable_attribute :registration_terms, String

        validates :registration_terms, translatable_presence: true, if: ->(form) { form.registrations_enabled? }
        validates :available_slots, numericality: { greater_than_or_equal_to: 0 }, if: ->(form) { form.registrations_enabled? }
        validate :available_slots_greater_than_or_equal_to_registrations_count, if: ->(form) { form.registrations_enabled? && form.available_slots.positive? }

        private

        def available_slots_greater_than_or_equal_to_registrations_count
          errors.add(:available_slots, :invalid) if available_slots < meeting.registrations.count
        end

        def meeting
          @meeting ||= context[:meeting]
        end
      end
    end
  end
end
