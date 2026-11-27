# frozen_string_literal: true

module Decidim
  class PrivateDownload
    class InvalidTokenError < StandardError; end

    VERIFIER_PURPOSE = :private_download

    def self.for(record, attachment_name:, variant: nil)
      new(record:, attachment_name:, variant:)
    end

    def self.from_token(token)
      payload = verifier.verify(token, purpose: VERIFIER_PURPOSE).with_indifferent_access
      record = GlobalID::Locator.locate(payload[:gid])

      raise InvalidTokenError if record.blank?

      new(record:, attachment_name: payload[:attachment_name], variant: payload[:variant])
    rescue ActiveSupport::MessageVerifier::InvalidSignature, TypeError
      raise InvalidTokenError
    end

    def self.verifier
      @verifier ||= ActiveSupport::MessageVerifier.new(Rails.application.secret_key_base, serializer: JSON)
    end

    def initialize(record:, attachment_name:, variant: nil)
      @record = record
      @attachment_name = attachment_name.to_s
      @variant = variant.presence&.to_sym
    end

    attr_reader :variant

    def token
      self.class.verifier.generate(
        {
          gid: record.to_global_id.to_s,
          attachment_name:,
          variant:
        }.compact,
        purpose: VERIFIER_PURPOSE
      )
    end

    def attachment
      record.public_send(attachment_name)
    end

    def representation
      @representation ||= variant.present? ? variant_representation : attachment
    end

    def attached?
      attachment.respond_to?(:attached?) && attachment.attached?
    end

    def authorized_for?(user)
      return false unless record.respond_to?(:private_download_authorized?)

      record.private_download_authorized?(user, attachment_name)
    end

    private

    attr_reader :record, :attachment_name

    def variant_representation
      return attachment unless record.respond_to?(:attached_uploader)

      uploader = record.attached_uploader(attachment_name.to_sym)
      representation = uploader.variant(variant)
      representation.respond_to?(:processed) ? representation.processed : representation
    end
  end
end
