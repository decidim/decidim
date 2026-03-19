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

        attachments_attribute :documents

        validates :title, translatable_presence: true
        validates :results_availability, inclusion: { in: Decidim::Elections::Election::RESULTS_AVAILABILITY_OPTIONS }
        validates :start_at, date: { before: :end_at }, unless: :manual_start?
        validates :start_at, date: { after: proc { Time.current } }, if: :scheduled_election?
        validates :manual_start, acceptance: true, if: :per_question_not_started?
        validates :end_at, presence: true
        validates :end_at, date: { after: :start_at }, if: ->(f) { f.start_at.present? && f.end_at.present? }
        validates :end_at, date: { after: proc { Time.current } }, if: :scheduled_election?

        def map_model(election)
          self.manual_start = election.start_at.blank?
          self.documents = election.attachments.ids
          self.add_documents = election.attachments.map { |att| { id: att.id, title: att.title } }
        end

        def documents=(value)
          case value
          when String
            super(parse_string_documents(value))
          when Integer
            super([value])
          else
            super
          end
        end

        def documents
          result = super

          if should_use_add_documents?(result)
            extract_ids_from_add_documents
          else
            result.is_a?(Array) ? result : []
          end
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

        private

        def should_use_add_documents?(result)
          (result.blank? || result.is_a?(String)) && add_documents.present?
        end

        def extract_ids_from_add_documents
          add_documents
            .select { |doc| doc.is_a?(Hash) && (doc[:id].present? || doc["id"].present?) }
            .map { |doc| (doc[:id] || doc["id"]).to_i }
        end

        def parse_string_documents(value)
          return [] if value.blank?

          parse_document_ids(value)
        end

        def parse_document_ids(value)
          ids = begin
            Array(JSON.parse(value))
          rescue JSON::ParserError
            value.split(",").map(&:strip)
          end

          ids.map(&:to_i).reject(&:zero?)
        end
      end
    end
  end
end
