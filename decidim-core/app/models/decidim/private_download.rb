# frozen_string_literal: true

module Decidim
  class PrivateDownload
    class InvalidTokenError < StandardError; end

    VERIFIER_PURPOSE = :private_download

    def self.for(record, attachment_name:)
      new(record:, attachment_name:)
    end

    def self.from_token(token)
      payload = verifier.verify(token, purpose: VERIFIER_PURPOSE).with_indifferent_access
      record = GlobalID::Locator.locate(payload[:gid])

      raise InvalidTokenError if record.blank?

      new(record:, attachment_name: payload[:attachment_name])
    rescue ActiveSupport::MessageVerifier::InvalidSignature, TypeError
      raise InvalidTokenError
    end

    def self.verifier
      @verifier ||= ActiveSupport::MessageVerifier.new(Rails.application.secret_key_base, serializer: JSON)
    end

    def initialize(record:, attachment_name:)
      @record = record
      @attachment_name = attachment_name.to_s
    end

    def token
      self.class.verifier.generate(
        {
          gid: record.to_global_id.to_s,
          attachment_name:
        },
        purpose: VERIFIER_PURPOSE
      )
    end

    def attachment
      record.public_send(attachment_name)
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
  end
end
