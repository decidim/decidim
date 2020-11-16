# frozen_string_literal: true

module Decidim
  module Core
    # This interface represents a fingerprintable object.
    module FingerprintInterface
      include GraphQL::Schema::Interface
      # name "FingerprintInterface"
      description "An interface that can be used in fingerprintable objects."

      field :fingerprint, Decidim::Core::FingerprintType, null: false, description: "This object's fingerprint"
    end
  end
end
