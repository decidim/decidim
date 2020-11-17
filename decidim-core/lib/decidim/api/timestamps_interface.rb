# frozen_string_literal: true

module Decidim
  module Core
    # This interface represents an object with standard create_at and updated_at timestamps.
    module TimestampsInterface
      include GraphQL::Schema::Interface
      # name "TimestampsInterface"
      description "An interface that can be used in objects with created_at and updated_at attributes"

      field :createdAt, Decidim::Core::DateTimeType, null: false, description: "The date and time this object was created"
      field :updatedAt, Decidim::Core::DateTimeType, null: false, description: "The date and time this object was updated"

      def createdAt
        object.created_at
      end

      def updatedAt
        object.updated_at
      end
    end
  end
end
