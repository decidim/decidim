# frozen_string_literal: true

module Decidim
  module Proposals
    # A form object to be used when public users want to create a proposal.
    class ProposalForm < Decidim::Form
      include Decidim::TranslatableAttributes
      include Decidim::AttachmentAttributes
      include Decidim::HasUploadValidations
      include Decidim::HasTaxonomyFormAttributes

      mimic :proposal

      attribute :title, String
      attribute :body, Decidim::Attributes::CleanString
      attribute :body_template, String
      attribute :address, String
      attribute :latitude, Float
      attribute :longitude, Float
      attribute :attachment, AttachmentForm

      attachments_attribute :documents

      validates :title, :body, presence: true
      validates :title, :body, etiquette: true
      validates :title, length: { in: 15..150 }
      validates :body, proposal_length: {
        minimum: 15,
        maximum: ->(record) { record.component.settings.proposal_length }
      }
      validates :address, geocoding: true, if: ->(form) { form.has_address? && !form.geocoded? }

      validate :body_is_not_bare_template
      validate :notify_missing_attachment_if_errored

      alias component current_component

      def map_model(model)
        self.title = translated_attribute(model.title)
        self.body = translated_attribute(model.body)

        presenter = ProposalPresenter.new(model)
        self.body = presenter.editor_body(all_locales: body.is_a?(Hash))

        self.documents = model.attachments
      end

      def participatory_space_manifest
        @participatory_space_manifest ||= current_component.participatory_space.manifest.name
      end

      def geocoding_enabled?
        Decidim::Map.available?(:geocoding) && current_component.settings.geocoding_enabled?
      end

      def has_address?
        geocoding_enabled? && address.present?
      end

      def geocoded?
        latitude.present? && longitude.present?
      end

      private

      def body_is_not_bare_template
        return if body_template.blank?

        errors.add(:body, :cant_be_equal_to_template) if body.presence == body_template.presence
      end

      # This method will add an error to the "add_documents" field only if there is any error
      # in any other field. This is needed because when the form has an error, the attachment
      # is lost, so we need a way to inform the user of this problem.
      def notify_missing_attachment_if_errored
        errors.add(:add_documents, :needs_to_be_reattached) if errors.any? && add_documents.present?
      end
    end
  end
end
