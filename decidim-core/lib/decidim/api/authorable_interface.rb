# frozen_string_literal: true

module Decidim
  module Core
    # This interface represents a commentable object.
    AuthorableInterface = GraphQL::InterfaceType.define do
      name "AuthorableInterface"
      description "An interface that can be used in authorable objects."

      field :author, !Decidim::Core::AuthorInterface, "The comment's author" do
        resolve lambda { |obj, _args, _ctx|
          obj.user_group || obj.author
        }
      end
    end
  end
end
