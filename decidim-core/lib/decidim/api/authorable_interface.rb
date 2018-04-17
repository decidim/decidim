# frozen_string_literal: true

module Decidim
  module Core
    # This interface represents a commentable object.
    AuthorableInterface = GraphQL::InterfaceType.define do
      name "AuthorableInterface"
      description "An interface that can be used in authorable objects."

      field :author, !Decidim::Core::AuthorInterface, "The comment's author", property: :normalized_author
    end
  end
end
