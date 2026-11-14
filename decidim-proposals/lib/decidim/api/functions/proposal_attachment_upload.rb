# frozen_string_literal: true

module Decidim
  module Proposals
    # Builds the attachment params the proposal commands consume through
    # `Decidim::MultipleAttachmentsMethods`.
    #
    # The files arrive in the same multipart request as the mutation, so each of
    # them is checked with the shared upload rules before the blob is stored, and
    # the form receives the signed id of the blob instead of the upload itself.
    #
    # The uploads are only accepted when the component allows attachments. Without
    # that setting the files would be stored as blobs which are never attached to
    # a record, so the request is refused instead of silently ignoring them.
    module ProposalAttachmentUpload
      include Decidim::Core::FileUpload

      # The `add_attachments` params for the form, one hash per uploaded file.
      def attachment_params(attachments)
        return [] if attachments.blank?

        raise Decidim::Api::Errors::ValidationError, I18n.t("decidim.api.errors.attachments_not_allowed") unless current_component.settings.attachments_allowed?

        attachments.map do |attachment|
          params = { file: create_blob!(attachment.file).signed_id }

          # The title is only added when it is given, so the command keeps the
          # empty title it uses for the attachments without one.
          params[:title] = attachment.title if attachment.title.present?

          params
        end
      end
    end
  end
end
