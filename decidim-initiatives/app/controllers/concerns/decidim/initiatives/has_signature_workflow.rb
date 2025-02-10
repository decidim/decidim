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
        helper_method :signature_has_steps?, :ephemeral_signature_workflow?

        delegate :signature_form_class, :sms_mobile_phone_form_class, :sms_mobile_phone_validator_class, :sms_code_validator_class, to: :signature_workflow_manifest

        def ephemeral_signature_workflow?
          signature_workflow_manifest.ephemeral
        end

        private

        def signature_workflow_manifest
          @signature_workflow_manifest ||= current_initiative.type.signature_workflow_manifest || Decidim::Initiatives::SignatureWorkflowManifest.new
        end

        def signature_has_steps?
          return unless current_initiative

          signature_workflow_manifest.sms_verification || signature_form_class.requires_extra_attributes?
        end
      end
    end
  end
end
