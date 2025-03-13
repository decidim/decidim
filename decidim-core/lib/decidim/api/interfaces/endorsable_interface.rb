# frozen_string_literal: true

module Decidim
  module Core
    # This interface represents an object capable of endorsements.
    module EndorsableInterface
      include Decidim::Api::Types::BaseInterface
      description "An interface that can be used in objects with endorsements"

      field :endorsements, [Decidim::Core::AuthorInterface, { null: true }], "The endorsements of this object.", null: false

      field :endorsements_count, Integer, description: "The total amount of endorsements the object has received", null: true

      def endorsements
        object.endorsements.map(&:author)
      end
    end
  end
end
