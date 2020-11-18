# frozen_string_literal: true

module Decidim
  module Core
    # This interface represents an object with standard create_at and updated_at timestamps.
    module TimestampsInterface
      include GraphQL::Schema::Interface
      # name "TimestampsInterface"
      description "An interface that can be used in objects with created_at and updated_at attributes"

      field :createdAt, Decidim::Core::DateTimeType, null: false, description: "The date and time this object was created"do
        def resolve_field(object, args, context)
          object.created_at
        end
      end
      field :updatedAt, Decidim::Core::DateTimeType, null: false, description: "The date and time this object was updated"do
        def resolve_field(object, args, context)
          object.updated_at
        end
      end
    end
  end
end
