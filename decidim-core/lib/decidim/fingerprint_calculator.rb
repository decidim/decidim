# frozen_string_literal: true

require "digest"

module Decidim
  class FingerprintCalculator
    alias to_s fingerprint

    def initialize(object, data)
      @object = object
      @data = data
    end

    def fingerprint
      @fingerprint ||= Digest::SHA256.hexdigest(data)
    end

    def source
      @source ||= JSON.generate(sort_hash(@data))
    end

    private

    def sort_hash(hash)
      return hash unless hash.is_a?(Hash)

      Hash[
        hash.map { |key, value| [key, sort_hash(value)] }
            .sort_by { |key, _value| key }
      ]
    end
  end
end
