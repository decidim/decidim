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
        attribute :results_availability, String, default: "after_end"
        attribute :attachment, AttachmentForm

        attachments_attribute :attachments

        validates :title, translatable_presence: true
        validates :results_availability, inclusion: { in: Decidim::Elections::Election::RESULTS_AVAILABILITY_OPTIONS }
        validates :start_at, date: { before: :end_at }, unless: :manual_start?
        validates :start_at, date: { after: proc { Time.current } }, if: ->(f) { f.election&.scheduled? && f.start_at.present? }
        validates :manual_start, acceptance: true, if: :per_question_not_started?
        validates :end_at, presence: true
        validates :end_at, date: { after: :start_at }, if: ->(f) { f.start_at.present? && f.end_at.present? }
        validates :end_at, date: { after: proc { Time.current } }, if: :scheduled_election?

        def map_model(election)
          self.manual_start = election.start_at.blank?
          self.attachments = election.attachments.ids
          self.add_attachments = election.attachments.map { |att| { id: att.id, title: att.title } }
        end

        def results_availability_labels
          Decidim::Elections::Election::RESULTS_AVAILABILITY_OPTIONS.map do |type|
            [type, I18n.t("decidim.elections.admin.elections.form.results_availability.#{type}")]
          end
        end

        def per_question_not_started?
          results_availability == "per_question" && start_at.blank?
        end

        def election
          @election ||= context[:election]
        end

        def scheduled_election?
          election&.scheduled?
        end
      end
    end
  end
end
