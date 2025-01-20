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
        helper_method :signature_has_steps?

        delegate :signature_form_class, :sms_mobile_phone_form_class, :sms_mobile_phone_validator_class, :sms_code_validator_class, to: :signature_workflow_manifest

        private

        def signature_workflow_manifest
          @signature_workflow_manifest ||= begin
            handler_name = current_initiative.type.document_number_authorization_handler
            Decidim::Initiatives::Signatures.find_workflow_manifest(handler_name) || Decidim::Initiatives::SignatureWorkflowManifest.new
          end
        end

        def signature_has_steps?
          return unless current_initiative

          signature_workflow_manifest.sms_verification || signature_form_class.requires_extra_attributes?
        end
      end
    end
  end
end
