# frozen_string_literal: true

require "securerandom"

module Decidim
  module Verifications
    module Sms
      # A form object to be used when public users want to get verified using their phone.
      class MobilePhoneForm < AuthorizationHandler
        attribute :mobile_phone_number, String

        validates :mobile_phone_number, :verification_code, :sms_gateway, presence: true

        def handler_name
          "sms"
        end

        # A mobile phone can only be verified once but it should be private.
        def unique_id
          Digest::SHA256.hexdigest(
            "#{mobile_phone_number}-#{Rails.application.secret_key_base}"
          )
        end

        # When there is a phone number, sanitize it allowing only numbers and +.
        def mobile_phone_number
          return unless super

          super.gsub(/[^+0-9]/, "")
        end

        # The verification metadata to validate in the next step.
        def verification_metadata
          {
            verification_code:,
            code_sent_at: Time.current
          }
        end

        private

        def verification_code
          return unless sms_gateway
          return @verification_code if defined?(@verification_code)

          return unless sms_gateway.new(mobile_phone_number, generated_code, sms_gateway_context).deliver_code

          @verification_code = generated_code
        end

        def sms_gateway
          Decidim.sms_gateway_service.to_s.safe_constantize
        end

        def sms_gateway_context
          { organization: user&.organization }
        end

        def generated_code
          @generated_code ||= format("%06d", SecureRandom.random_number(1_000_000))
        end
      end
    end
  end
end
