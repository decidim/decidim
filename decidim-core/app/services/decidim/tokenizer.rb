# frozen_string_literal: true

require "openssl"

module Decidim
  # This class is used to generate secure tokens
  class Tokenizer
    #
    # Initializes the Tokenizer.
    #
    # salt      - The salt fr the encryption (it should be at leas 30 chars long)
    # length    - How long the key generated should be (in bytes)
    #
    def initialize(salt: nil, length: 32)
      @salt = salt.presence || Tokenizer.random_salt
      @length = length
    end

    def self.random_salt
      SecureRandom.hex(32)
    end

    attr_reader :salt, :length

    # returns a securely generated string of bytes
    def digest(string)
      OpenSSL::PKCS5.pbkdf2_hmac(string.to_s, salt, 20_000, length, "sha256")
    end

    def int_digest(string)
      digest(string.to_s).bytes.inject { |a, b| (a << 8) + b }
    end

    def hex_digest(string)
      digest(string.to_s).bytes.map { |c| c.ord.to_s(16) }.join
    end
  end
end
