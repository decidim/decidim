# frozen_string_literal: true

module Decidim
  module Core
    # This interface represents a commentable object.
    AuthorableInterface = GraphQL::InterfaceType.define do
      name "AuthorableInterface"
      description "An interface that can be used in authorable objects."

      field :author, Decidim::Core::AuthorInterface, "The resource author" do
        # can be an Authorable or a Coauthorable
        resolve ->(authorable, _, _) {
          if authorable.respond_to?(:normalized_author)
            authorable&.normalized_author
          elsif authorable.respond_to?(:creator_identity)
            authorable&.creator_identity
          end
        }
      end
    end
  end
end
