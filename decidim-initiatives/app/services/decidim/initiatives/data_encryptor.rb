# frozen_string_literal: true

module Decidim
  module Initiatives
    # Service to encrypt and decrypt metadata
    class DataEncryptor < Decidim::AttributeEncryptor
      def initialize(secret: "default", **)
        Decidim.deprecator.warn("Decidim::Initiatives::DataEncryptor is deprecated, and we will remove it in Decidim 0.33. Please use Decidim::AttributeEncryptor instead.")
        super(secret: secret || "default", **)
      end
    end
  end
end
