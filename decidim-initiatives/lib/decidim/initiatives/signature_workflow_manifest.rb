# frozen_string_literal: true

# require "decidim/settings_manifest"
require "decidim/initiatives/default_signature_authorizer"

module Decidim
  module Initiatives
    autoload :DefaultSignatureAuthorizer, "decidim/initiatives/default_signature__authorizer"

    #
    # This class serves as a DSL to declaratively specify a signature method.
    #
    # To define a direct signature method, you need to specify the `form`
    # attribute as a `Decidim::Form` that will be valid if the signature
    # process is valid.
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

      # For the moment no engines are going to be defined
      # attribute :engine, Rails::Engine, **{}
      # attribute :admin_engine, Rails::Engine, **{}
      attribute :name, String
      attribute :form, String
      attribute :action_authorizer, String
      attribute :authorization_handler_form, String, default: nil
      attribute :save_authorizations, Boolean, default: true
      attribute :promote_authorization_validation_errors, Boolean, default: false
      attribute :ephemeral, Boolean, default: false
      attribute :sms_verification, Boolean, default: true
      attribute :sms_mobile_phone_form, String, default: nil
      attribute :sms_mobile_phone_validator, String, default: nil
      attribute :sms_code_validator, String, default: nil

      validates :name, presence: true
      validates :form, presence: true

      alias key name

      def fullname
        I18n.t("#{key}.name", scope: "decidim.signature_workflows", default: name.humanize)
      end

      def action_authorizer_class
        if action_authorizer.present?
          action_authorizer.constantize
        else
          DefaultSignatureAuthorizer
        end
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

      # For the moment this will not be used
      # # Public: Adds configurable settings for this verification workflow. It
      # # uses the DSL specified under `Decidim::SettingsManifest`.
      # #
      # # &block - The DSL present on `Decidim::SettingsManifest`
      # #
      # # Examples:
      # #
      # #   workflow.options do |options|
      # #     options.attribute :minimum_age, type: :integer, default: 18
      # #   end
      # #
      # # Returns nothing.
      # def options
      #   @options ||= SettingsManifest.new

      #   yield(@options) if block_given?

      #   @options
      # end
    end
  end
end
