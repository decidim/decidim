# frozen_string_literal: true

require "digest"

module Decidim
  class FingerprintCalculator
    def initialize(data)
      @data = data
    end

    def value
      @value ||= Digest::SHA256.hexdigest(source)
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
