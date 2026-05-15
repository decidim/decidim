# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A form object to be used when admin users want to create a proposal.
      class ProposalForm < Decidim::Proposals::Admin::ProposalBaseForm
        include Decidim::HasUploadValidations
        include Decidim::AttachmentAttributes

        translatable_attribute :title, String do |field, _locale|
          validates field, length: { in: 15..150 }, if: proc { |resource| resource.send(field).present? }
        end
        translatable_attribute :body, Decidim::Attributes::RichText
        attribute :attachment, AttachmentForm

        attachments_attribute :documents

        validates :title, :body, translatable_presence: true
        validates :title, :body, translated_etiquette: true

        validate :notify_missing_attachment_if_errored

        def map_model(model)
          super
          presenter = ProposalPresenter.new(model)

          self.title = presenter.title(all_locales: title.is_a?(Hash))
          self.body = presenter.editor_body(all_locales: body.is_a?(Hash))
          self.documents = model.attachments.ids
          self.add_documents = model.attachments.map { |att| { id: att.id, title: att.title } }
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

        def notify_missing_attachment_if_errored
          errors.add(:add_documents, :needs_to_be_reattached) if errors.any? && add_documents.present?
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
