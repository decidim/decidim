# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # A concern with the components needed when you want a model to be able to create
  # links from it to another resource.
  module Paddable
    extend ActiveSupport::Concern
    include HasComponent
    include HasReference

    included do
      # Public: The String with the URL to access the pad with read/write permissions.
      def pad_public_url
        return unless pad

        build_pad_url pad.id
      end

      # Public: The String with the URL to access the pad with read permissions only.
      def pad_read_only_url
        return unless pad

        build_pad_url pad.read_only_id
      end

      # Public: Returns a EtherpadLite::Pad instance if Etherpad is configured.
      def pad
        return if Decidim.etherpad.blank?
        return unless component.settings.enable_pads_creation

        @pad ||= etherpad.pad(pad_id)
      end

      # Public: Whether to show the pad or not.
      #
      # True by default if a Pad exists.
      #
      # This should be overwritten at the included model to customise the rules.
      # Returns a Boolean.
      def pad_is_visible?
        pad
      end

      # Public: Whether the pad is writable or not.
      #
      # True by default if a Pad exists.
      #
      # This should be overwritten at the included model to customise the rules.
      # Returns a Boolean.
      def pad_is_writable?
        pad
      end

      private

      def etherpad
        @etherpad ||= EtherpadLite.connect(
          Decidim.etherpad.fetch(:server),
          Decidim.etherpad.fetch(:api_key),
          Decidim.etherpad.fetch(:api_version, "1.2.1")
        )
      end

      def pad_id
        @pad_id ||= [reference, token].join("-").slice(0, 50)
      end

      # compatibilize with old versions if no salt available (less secure)
      def token
        if defined?(salt) && salt.present?
          tokenizer = Decidim::Tokenizer.new(salt: salt)
          return tokenizer.hex_digest(id)
        end

        Digest::MD5.hexdigest("#{id}-#{Rails.application.secrets.secret_key_base}")
      end

      def build_pad_url(id)
        [
          Decidim.etherpad.fetch(:server),
          "p",
          id
        ].join("/")
      end
    end
  end
end
