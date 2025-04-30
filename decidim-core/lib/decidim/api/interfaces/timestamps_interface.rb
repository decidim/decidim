# frozen_string_literal: true

module Decidim
  module Core
    # This interface represents an object with standard create_at and updated_at timestamps.
    module TimestampsInterface
      include Decidim::Api::Types::BaseInterface
      description "An interface that can be used in objects with created_at and updated_at attributes"

      field :created_at, Decidim::Core::DateTimeType, description: "The date and time this object was created", null: true
      field :updated_at, Decidim::Core::DateTimeType, description: "The date and time this object was updated", null: true
    end
  end
end
