# frozen_string_literal: true

module Decidim
  module Core
    # This interface represents a followable object.
    module FollowableInterface
      include Decidim::Api::Types::BaseInterface
      description "An interface that can be used in followable objects."

      field :follows_count, GraphQL::Types::Int, "The number of followers of the resource", null: true
    end
  end
end
