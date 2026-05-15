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
    # All the attributes except the name are optional. If no attributes are set
    # there are default values for them and the signature flow will be direct
    # without steps and metadata stored in the initiatives_vote
    #
    # Signature workflow attributes:
    # - :form (String) (optional) The name of the form object class responsible
    #     for collecting and validating the data to create the initiative votes.
    #     This class should be inherited from
    #     Decidim::Initiatives::SignatureHandler and can define a set of
    #     attributes to collect user personal data. If extra attributes are
    #     defined a collect personal data step will be enabled. This class also
    #     can define an unique_id to avoid duplicated votes based on the
    #     personal data and a metadata hash that will be encrypted in the vote
    #     creation. The class can also collect a hash of metadata that will be
    #     passed to an authorization handler if defined in the workflow. The
    #     class is also responsible to define the scopes associated with the
    #     votes. The main class by default detects the scopes candidates and
    #     the inherited class can define a signature_scope_id based on the data
    #     provided by the user.
    #     (default: "Decidim::Initiatives::SignatureHandler")
    # - :authorization_handler_form (String) (optional) If this authorization
    #     handler class name is set the previous form will create and validate
    #     an instance of it from the params defined in it (by default the
    #     collected metadata and the user). If the authorization is invalid the
    #     signature is blocked. (default: nil)
    # - :save_authorizations (Boolean) (optional) This option allows the
    #     workflow to save or update if already exist the authorization
    #     associated to the previous authorization handler. Note that if this
    #     option is set to false the user will be required to have been
    #     previously authorized with the method associated to the authorization
    #     handler. The authorization is searched by the organization, the user
    #     and the authorization handler name. If this class is not defined,
    #     class Decidim::Initiatives::DefaultSignatureAuthorizer is used,
    #     which inherits from Decidim::Verifications::DefaultActionAuthorizer
    #     and checks the authorization status. (default: true)
    # - :ephemeral (Boolean) (optional) This option enables the possibility for
    #     users to sign without prior registration through an ephemeral session.
    #     To allow ephemeral sessions to be recovered o transferred to regular
    #     users authorizations must be stored in the process so an
    #     authorization_handler_form must be defined and the save_authorizations
    #     option must not be set to false. If those settings are not properly
    #     configured this option will be ignored and the workflow will not
    #     allow ephemeral sessions. (default: false)
    # - :promote_authorization_validation_errors (Boolean) (optional) If set
    #     to true, errors in the personal data passed to the authorization
    #     handler form will be displayed next to the corresponding fields
    #     in the collection of personal data. Note that this option may provide
    #     information about personal data to the user. (default: false)
    # - :action_authorizer (String) This is the name of the action authorizer
    #     class responsible for checking the status of the authorization
    #     associated to the signature. If this class is not defined, the
    #     authorization status will be ignored. You can define a handler
    #     inherited from Decidim::Initiatives::DefaultSignatureAuthorizer which
    #     inherits from Decidim::Verifications::DefaultActionAuthorizer and
    #     checks the authorization status with an instance initialized only
    #     with the authorization (without a component or a resource).
    #     (default: nil)
    # - :sms_verification (Boolean) (optional) This option enables an
    #     additional SMS verification step. It uses by default the sms
    #     verification flow defined in decidim_verifications and expects the
    #     user to have previously created an SMS authorization validating
    #     their phone number. This behaviour can be changed defining the
    #     following attributes. (default: false)
    # - :sms_mobile_phone_form_class (String) (optional) The name of the class
    #     responsible for starting the users phone verification. It uses the
    #     default form defined in decidim_initiatives.
    #     (default: "Decidim::Verifications::Sms::MobilePhoneForm")
    # - :sms_mobile_phone_validator (String) (optional) The name of the command
    #     class responsible for checking if the mobile phone provided by the
    #     user has an authorization associated to the sms_mobile_form_class
    #     and delivering the sms code
    #     (default: "Decidim::Initiatives::ValidateMobilePhone")
    # - :sms_code_validator_class (String) (optional) The name of the command
    #     class responsible for checking if the SMS code provided by the user
    #     is valid. (default: "Decidim::Initiatives::ValidateSmsCode")
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
      validate :ephemeral_configuration

      alias key name

      def fullname
        I18n.t("#{key}.name", scope: "decidim.signature_workflows", default: name.humanize)
      end

      def signature_form_class
        form&.safe_constantize || Decidim::Initiatives::SignatureHandler
      end

      def action_authorizer_class
        return if action_authorizer.blank?

        action_authorizer.safe_constantize || DefaultSignatureAuthorizer
      end

      def authorization_handler_form_class
        authorization_handler_form&.safe_constantize
      end

      # If no authorization handler is set or the save_authorizations option
      # is disabled the workflow will not be able to save the user verification
      # attributes necessary to recover the user session or transfer their
      # activities
      def ephemeral?
        return if authorization_handler_form_class.blank? || !save_authorizations

        ephemeral
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

      def ephemeral_configuration
        return unless Rails.env.development?
        return unless ephemeral

        raise StandardError, "Wrong configuration of ephemeral signature workflow #{fullname}" if !save_authorizations || authorization_handler_form.blank?
      end
    end
  end
end
