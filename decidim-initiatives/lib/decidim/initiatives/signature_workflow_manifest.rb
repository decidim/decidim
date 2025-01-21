# frozen_string_literal: true

# require "decidim/settings_manifest"
require "decidim/initiatives/default_signature_authorizer"

module Decidim
  module Initiatives
    # This class serves as a DSL to declaratively specify a signature method.
    #
    # To define a direct signature method, you need to specify the `form`
    # attribute as a `Decidim::Form` that will be valid if the signature
    # process is valid. If no form is provided the application assumes that the
    # form class is `Decidim::Initiatives::SignatureHandler`
    #
    # An example of declaration of a workflow:
    #
    # Decidim::Initiatives::Signatures.register_workflow(:dummy_signature_handler) do |workflow|
    #   workflow.form = "DummySignatureHandler"
    #   workflow.authorization_handler_form = "DummyAuthorizationHandler"
    #   workflow.action_authorizer = "DummySignatureHandler::DummySignatureActionAuthorizer"
    #   workflow.promote_authorization_validation_errors = true
    #   workflow.sms_verification = true
    # end
    #
    class SignatureWorkflowManifest
      include ActiveModel::Model
      include Decidim::AttributeObject::Model

      attribute :name, String
      attribute :form, String
      attribute :authorization_handler_form, String, default: nil
      attribute :action_authorizer, String
      attribute :save_authorizations, Boolean, default: true
      attribute :promote_authorization_validation_errors, Boolean, default: false
      attribute :ephemeral, Boolean, default: false
      attribute :sms_verification, Boolean, default: false
      attribute :sms_mobile_phone_form, String, default: nil
      attribute :sms_mobile_phone_validator, String, default: nil
      attribute :sms_code_validator, String, default: nil

      validates :name, presence: true

      alias key name

      def fullname
        I18n.t("#{key}.name", scope: "decidim.signature_workflows", default: name.humanize)
      end

      def signature_form_class
        form&.safe_constantize || Decidim::Initiatives::SignatureHandler
      end

      def action_authorizer_class
        if action_authorizer.present?
          action_authorizer.constantize
        else
          DefaultSignatureAuthorizer
        end
      end

      def authorization_handler_form_class
        authorization_handler_form&.safe_constantize
      end

      def sms_mobile_phone_form_class
        return unless sms_verification

        sms_mobile_phone_form&.safe_constantize || Decidim::Verifications::Sms::MobilePhoneForm
      end

      def sms_mobile_phone_validator_class
        return unless sms_verification

        sms_mobile_phone_validator&.safe_constantize || Decidim::Initiatives::ValidateMobilePhone
      end

      def sms_code_validator_class
        return unless sms_verification

        sms_code_validator&.safe_constantize || Decidim::Initiatives::ValidateSmsCode
      end
    end
  end
end
