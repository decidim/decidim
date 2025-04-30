# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # Form to create or update an election.
      class ElectionForm < Decidim::Form
        mimic :election

        include Decidim::HasUploadValidations
        include Decidim::AttachmentAttributes
        include Decidim::TranslatableAttributes

        translatable_attribute :title, String
        translatable_attribute :description, Decidim::Attributes::RichText

        attribute :start_at, DateTime
        attribute :end_at, DateTime
        attribute :manual_start, Boolean, default: true
        attribute :results_availability, String, default: "real_time"
        attribute :attachment, AttachmentForm

        attachments_attribute :photos

        validates :title, translatable_presence: true
        validates :description, translatable_presence: true
        validates :results_availability, inclusion: { in: %w(real_time after_end question_by_question) }

        validate :validate_start_at_presence
        validate :validate_end_at_presence
        validate :validate_start_before_end
        validate :validate_end_not_in_past_if_manual

        private

        def validate_start_at_presence
          return if manual_start?

          errors.add(:start_at, :blank) if start_at.blank?
        end

        def validate_end_at_presence
          return if manual_start?

          errors.add(:end_at, :blank) if end_at.blank?
        end

        def validate_start_before_end
          return if start_at.blank? || end_at.blank?

          errors.add(:start_at, :invalid) if start_at >= end_at
        end

        def validate_end_not_in_past_if_manual
          return unless manual_start?

          if end_at.blank?
            errors.add(:end_at, :blank)
          elsif end_at < Time.zone.now
            errors.add(:end_at, :invalid)
          end
        end
      end
    end
  end
end
