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

        attribute :start_at, Decidim::Attributes::TimeWithZone
        attribute :end_at, Decidim::Attributes::TimeWithZone
        attribute :manual_start, Boolean
        attribute :results_availability, String, default: "real_time"
        attribute :attachment, AttachmentForm

        attachments_attribute :photos

        validates :title, translatable_presence: true
        validates :results_availability, inclusion: { in: Decidim::Elections::Election::RESULTS_AVAILABILITY_OPTIONS }
        validates :start_at, date: { before: :end_at }, if: ->(f) { f.start_at.present? }
        validates :manual_start, absence: true, if: ->(f) { f.start_at.present? && !f.per_question? }
        validates :manual_start, acceptance: true, if: :per_question?
        validates :end_at, presence: true
        validates :end_at, date: { after: :start_at }, allow_blank: true, if: ->(f) { f.start_at.present? && f.end_at.present? }

        def map_model(election)
          self.manual_start = election.start_at.blank?
        end

        def results_availability_labels
          Decidim::Elections::Election::RESULTS_AVAILABILITY_OPTIONS.map do |type|
            [type, I18n.t("decidim.elections.admin.elections.form.results_availability.#{type}")]
          end
        end

        def per_question?
          results_availability == "per_question"
        end
      end
    end
  end
end
