# frozen_string_literal: true

module Decidim
  module AttributeObject
    # Backwards compatibility for legacy types. Provides accessors for the
    # legacy Virtus type classes that are mapped to ActiveModel types.
    module TypeMap
      # rubocop:disable Naming/ConstantName
      Boolean = :boolean
      # rubocop:enable Naming/ConstantName
    end
  end
end
