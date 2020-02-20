# frozen_string_literal: true

module Decidim
  module Core
    # This interface represents a coauthorable object.
    CoauthorableInterface = GraphQL::InterfaceType.define do
      name "CoauthorableInterface"
      description "An interface that can be used in coauthorable objects."

      field :authorsCount, types.Int do
        description "The total amount of co-authors that contributed to the proposal. Note that this field may include also non-user authors like meetings or the organization"
        property :coauthorships_count
      end

      field :author, Decidim::Core::AuthorInterface do
        description "The resource author. Note that this can be null on official proposals or meeting-proposals"
        resolve ->(resource, _, _) {
          author = resource.creator_identity
          author if author.is_a?(Decidim::User) || author.is_a?(Decidim::UserGroup)
        }
      end

      field :authors, !types[Decidim::Core::AuthorInterface] do
        description "The resource co-authors. Include only users or groups of users"
        property :user_identities
      end
    end
  end
end
