# frozen_string_literal: true

module Decidim
  module Core
    # This interface represents a attachable object.
    TimestampsInterface = GraphQL::InterfaceType.define do
      name "TimestampsInterface"
      description "An interface that can be used in objects created_at and updated_at attributes"

      field :createdAt, Decidim::Core::DateTimeType do
        description "The date and time this object was created"
        property :created_at
      end

      field :updatedAt, Decidim::Core::DateTimeType do
        description "The date and time this object was updated"
        property :updated_at
      end
    end
  end
end
