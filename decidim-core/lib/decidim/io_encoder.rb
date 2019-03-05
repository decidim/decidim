# frozen_string_literal: true

require "charlock_holmes"

module Decidim
  # This module encloses all methods to uniformize encodings from incoming
  # and outgoing data streams.
  #
  # Decidim takes UTF-8 as its official, internal encoding.
  #
  # *Incoming*
  # All data arriving from external sources with unknown encodings will be
  # transformed to UTF-8.
  #
  module IoEncoder
    def self.to_standard_encoding(inn)
      detection = CharlockHolmes::EncodingDetector.detect(inn)

      inn = CharlockHolmes::Converter.convert(inn, detection[:encoding], "UTF-8") if detection[:type] == :text
      inn
    end
  end
end
