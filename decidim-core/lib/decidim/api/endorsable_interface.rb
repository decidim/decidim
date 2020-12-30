# frozen_string_literal: true

module Decidim
  module Core
    # This interface represents an object capable of endorsements.
    module EndorsableInterface
      include Decidim::Api::Types::BaseInterface
      description "An interface that can be used in objects with endorsements"

      field :endorsements, [Decidim::Core::AuthorInterface, { null: true }], "The endorsements of this object.", null: false

      def endorsements
        object.endorsements.map(&:normalized_author)
      end

      field :endorsements_count, Integer, description: "The total amount of endorsements the object has received", null: true
    end
  end
end
