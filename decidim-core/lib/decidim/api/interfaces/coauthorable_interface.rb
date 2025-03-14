# frozen_string_literal: true

module Decidim
  module Core
    # This interface represents a coauthorable object.
    module CoauthorableInterface
      include Decidim::Api::Types::BaseInterface
      description "An interface that can be used in coauthorable objects."

      field :authors_count, Integer,
            method: :coauthorships_count,
            description: "The total amount of co-authors that contributed to the entity. Note that this field may include also non-user authors like meetings or the organization",
            null: true

      field :authors, [Decidim::Core::AuthorInterface, { null: true }],
            method: :user_identities,
            description: "The resource co-authors. Include only users or groups of users",
            null: false

      field :author, Decidim::Core::AuthorInterface,
            description: "The resource author. Note that this can be null on official proposals or meeting-proposals",
            null: true

      def author
        author = object.creator_identity
        author if author.is_a?(Decidim::User)
      end
    end
  end
end
