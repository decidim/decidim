# frozen_string_literal: true

module Decidim
  module Core
    # This interface represents an object capable of likes.
    module EndorsableInterface
      include Decidim::Api::Types::BaseInterface
      description "An interface that can be used in objects with likes"

      field :likes, [Decidim::Core::AuthorInterface, { null: true }], "The likes of this object.", null: false

      field :endorsements_count, Integer, description: "The total amount of likes the object has received", null: true

      def likes
        object.likes.map(&:author)
      end
    end
  end
end
