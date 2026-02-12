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
          # Set documents as IDs for the form
          self.documents = model.attachments.ids
          # Also ensure add_documents starts with existing attachments
          self.add_documents = model.attachments.map { |att| { id: att.id, title: att.title } }
        end

        # Override setter to handle String, Integer, and Array values from form params
        def documents=(value)
          case value
          when String
            # Parse string as JSON or comma-separated
            parsed = begin
              result = JSON.parse(value)
              Array(result).map(&:to_i)
            rescue JSON::ParserError
              value.split(",").map { |v| v.strip.to_i }
            end
            super(parsed)
          when Integer
            # Single integer, wrap in array
            super([value])
          else
            # Array or nil, pass through
            super
          end
        end

        def documents
          result = super

          # If we have add_documents but documents is blank/String, build from add_documents
          if (result.blank? || result.is_a?(String)) && add_documents.present?
            existing_ids = add_documents
                           .select { |doc| doc.is_a?(Hash) && (doc[:id].present? || doc["id"].present?) }
                           .map { |doc| (doc[:id] || doc["id"]).to_i }
            return existing_ids
          end

          # Otherwise return the result, converting non-Arrays to empty array
          result.is_a?(Array) ? result : []
        end

        def notify_missing_attachment_if_errored
          errors.add(:add_documents, :needs_to_be_reattached) if errors.any? && add_documents.present?
        end
      end
    end
  end
end
