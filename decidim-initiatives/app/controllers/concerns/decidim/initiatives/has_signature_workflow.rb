# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Initiatives
    # This concern is used to detect the form associated with the signature
    # workflow. If the manifest cannot be found the base SignatureHandler is
    # used.
    module HasSignatureWorkflow
      extend ActiveSupport::Concern

      included do
        private

        def signature_workflow_manifest
          @signature_workflow_manifest ||= begin
            # XXX - This is a temporary trick
            handler_name = current_initiative.type.document_number_authorization_handler.gsub("authorization", "signature")
            Decidim::Initiatives::Signatures.find_workflow_manifest(handler_name)
          end
        end

        def signature_form_class
          return Decidim::Initiatives::SignatureHandler if signature_workflow_manifest.blank?

          signature_workflow_manifest.form.constantize
        end
      end
    end
  end
end
