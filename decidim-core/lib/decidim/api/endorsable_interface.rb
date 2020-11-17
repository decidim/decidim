# frozen_string_literal: true

module Decidim
  module Core
    # This interface represents an object capable of endorsements.

    module EndorsableInterface
      include GraphQL::Schema::Interface
      # name "EndorsableInterface"
      # description "An interface that can be used in objects with endorsements"

      field :endorsements, !types[Decidim::Core::AuthorInterface], "The endorsements of this object." do
        def resolve(object:, arguments:, context:)
          object.endorsements.map(&:normalized_author)
        end
      end

      field :endorsementsCount, Int, null: true, description: "The total amount of endorsements the object has received"

      def endorsementsCount
        object.endorsements_count
      end
    end
  end
end
