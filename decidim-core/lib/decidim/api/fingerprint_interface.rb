# frozen_string_literal: true

module Decidim
  module Core
    # This interface represents a fingerprintable object.
    FingerprintInterface = GraphQL::InterfaceType.define do
      name "FingerprintInterface"
      description "An interface that can be used in fingerprintable objects."

      field :fingerprint, !Decidim::Core::FingerprintType, "This object's fingerprint"
    end
  end
end
