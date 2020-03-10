# frozen_string_literal: true

module Decidim
  module Core
    # This interface represents an object capable of endorsements.
    EndorsableInterface = GraphQL::InterfaceType.define do
      name "EndorsableInterface"
      description "An interface that can be used in objects with endorsements"

      field :endorsements, !types[Decidim::Core::AuthorInterface], "The endorsements of this object." do
        resolve ->(object, _, _) {
          object.endorsements.map(&:normalized_author)
        }
      end

      field :endorsementsCount, types.Int do
        description "The total amount of endorsements the object has received"
        property :endorsements_count
      end
    end
  end
end
