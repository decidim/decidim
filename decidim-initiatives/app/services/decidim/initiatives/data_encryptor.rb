# frozen_string_literal: true

module Decidim
  module Initiatives
    # Service to encrypt and decrypt metadata
    class DataEncryptor < Decidim::AttributeEncryptor
      def initialize(args = {})
        super(secret: args.fetch(:secret, "default"))
      end
    end
  end
end
