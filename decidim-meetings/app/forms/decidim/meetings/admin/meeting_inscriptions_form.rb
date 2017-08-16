# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This class holds a Form to update meeting inscriptions from Decidim's admin panel.
      class MeetingInscriptionsForm < Decidim::Form
        include TranslatableAttributes

        mimic :meeting

        attribute :inscriptions_enabled, Boolean
        attribute :available_slots, Integer
        translatable_attribute :inscription_terms, String

        validates :inscription_terms, translatable_presence: true, if: ->(form) { form.inscriptions_enabled? }
        validates :available_slots, numericality: { greater_than_or_equal_to: 0 }

        validate :available_slots_greater_than_or_equal_to_inscriptions_count, if: ->(form) { form.available_slots.positive? }

        private

        def available_slots_greater_than_or_equal_to_inscriptions_count
          errors.add(:available_slots, :invalid) if available_slots < meeting.inscriptions.count
        end

        def meeting
          @meeting ||= context[:meeting]
        end
      end
    end
  end
end
