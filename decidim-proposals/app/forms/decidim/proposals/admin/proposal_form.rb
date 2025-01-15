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

        validate :notify_missing_attachment_if_errored

        def map_model(model)
          super
          presenter = ProposalPresenter.new(model)

          self.title = presenter.title(all_locales: title.is_a?(Hash))
          self.body = presenter.editor_body(all_locales: body.is_a?(Hash))
          self.documents = model.attachments
        end

        def notify_missing_attachment_if_errored
          errors.add(:add_documents, :needs_to_be_reattached) if errors.any? && add_documents.present?
        end
      end
    end
  end
end
