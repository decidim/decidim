# frozen_string_literal: true

require "digest"

module Decidim
  # This class will generate a unique fingerprint given an arbitrarily deep hash,
  # ensuring that the same fingerprint will be generated regardless of ordering and
  # whether keys are symbols or strings.
  #
  class FingerprintCalculator
    # Public: Initializes the class with a source data to be fingerprinted.
    def initialize(data)
      @data = data
    end

    # Public: Generates a fingerprint hash.
    #
    # Returns a String with the fingerprint.
    def value
      @value ||= Digest::SHA256.hexdigest(source)
    end

    # Public: Returns the fingerprint source *before* hashing, so that it can be
    # inspected by the user.
    #
    # Returns a String with the JSON representation of the normalized data.
    def source
      @source ||= JSON.generate(sort_hash(@data))
    end

    private

    def sort_hash(hash)
      return hash unless hash.is_a?(Hash)

      hash.map { |key, value| [key, sort_hash(value)] }
          .sort_by { |key, _value| key }.to_h
    end
  end
end
