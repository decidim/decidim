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

        delegate :sms_mobile_phone_form_class, :sms_mobile_phone_validator_class, :sms_code_validator_class, to: :signature_workflow_manifest

        private

        def signature_workflow_manifest
          @signature_workflow_manifest ||= begin
            # XXX - This is a temporary trick
            handler_name = current_initiative.type.document_number_authorization_handler.gsub("authorization", "signature")
            Decidim::Initiatives::Signatures.find_workflow_manifest(handler_name) || Decidim::Initiatives::SignatureWorkflowManifest.new
          end
        end

        def signature_form_class
          return Decidim::Initiatives::SignatureHandler if signature_workflow_manifest.form.blank?

          signature_workflow_manifest.form.constantize
        end
      end
    end
  end
end
