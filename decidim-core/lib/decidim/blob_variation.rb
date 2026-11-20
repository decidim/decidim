# frozen_string_literal: true

require "base64"

module Decidim
  # Validates and normalizes the image transformation hashes that Decidim
  # stores inside blob references.
  #
  # The transformations are persisted as unsigned Base64 encoded JSON so that
  # they do not expire together with the Active Storage signed variation keys.
  # Because the renderer can encounter this format in user supplied content, it
  # must only accept operations that are known to be safe and supported.
  module BlobVariation
    MAX_KEY_LENGTH = 2048
    MAX_DIMENSION = 3840
    MAX_TRANSFORMATIONS = 8
    ALLOWED_FORMATS = %w(png jpg jpeg gif webp).freeze
    ALLOWED_KEYS = {
      "format" => :format,
      "resize_to_fit" => :resize_to_fit,
      "resize_to_fill" => :resize_to_fill,
      "resize_to_limit" => :resize_to_limit,
      "resize_and_pad" => :resize_and_pad
    }.freeze

    module_function

    # Parses an unsigned Base64 encoded JSON variation. Returns a hash with
    # symbol keys containing only supported transformations, or nil when the
    # value is invalid or contains anything that is not explicitly allowed.
    def parse(key)
      return if key.blank? || key.length > MAX_KEY_LENGTH

      decoded = Base64.strict_decode64(key)
      normalize_hash(ActiveSupport::JSON.decode(decoded))
    rescue ArgumentError, JSON::ParserError
      nil
    end

    # Normalizes an already decoded variation hash. Used by the parser before
    # storing a variation to ensure the persisted value only contains
    # supported transformations.
    def normalize_hash(hash)
      return unless hash.is_a?(Hash)
      return if hash.empty? || hash.size > MAX_TRANSFORMATIONS

      hash.each_with_object({}) do |(raw_key, raw_value), normalized|
        key = ALLOWED_KEYS[raw_key.to_s]
        break unless key

        valid, value = normalize_value(key, raw_value)
        break unless valid

        normalized[key] = value
      end
    end

    def normalize_value(key, value)
      case key
      when :format
        normalize_format(value)
      when :resize_to_fit, :resize_to_fill, :resize_to_limit, :resize_and_pad
        normalize_dimensions(value)
      else
        [false, nil]
      end
    end

    def normalize_format(value)
      return [false, nil] unless value.is_a?(String) || value.is_a?(Symbol)

      format = value.to_s.downcase
      return [false, nil] unless ALLOWED_FORMATS.include?(format)

      [true, format]
    end

    def normalize_dimensions(value)
      return [false, nil] unless value.is_a?(Array) && value.length.between?(1, 2)
      return [false, nil] if value.all?(&:nil?)
      return [false, nil] unless value.all? { |dimension| valid_dimension?(dimension) }

      [true, value]
    end

    def valid_dimension?(value)
      value.nil? || (value.is_a?(Integer) && value.positive? && value <= MAX_DIMENSION)
    end
  end
end
