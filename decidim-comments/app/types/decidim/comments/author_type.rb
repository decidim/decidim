# frozen_string_literal: true
module Decidim
  module Comments
    # This type represents an author who owns a resource
    AuthorType = GraphQL::ObjectType.define do
      name "Author"
      description "An author"

      field :name, !types.String, "The user's name"
      field :avatarUrl, !types.String, "The user's avatar url" do
        resolve ->(obj, _args, _ctx) { obj.avatar.url }
      end
    end
  end
end
