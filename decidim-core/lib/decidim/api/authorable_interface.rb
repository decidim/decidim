# frozen_string_literal: true

module Decidim
  module Core
    # This interface represents a commentable object.

    module AuthorableInterface
      include GraphQL::Schema::Interface
      # name "AuthorableInterface"
      # description "An interface that can be used in authorable objects."

      field :author, Decidim::Core::AuthorInterface, null: true, description: "The resource author" do
        # can be an Authorable or a Coauthorable
        def resolve(authorable:, arguments:, context:)
          if authorable.respond_to?(:normalized_author)
            authorable&.normalized_author
          elsif authorable.respond_to?(:creator_identity)
            authorable&.creator_identity
          end
        end
      end
    end
  end
end
