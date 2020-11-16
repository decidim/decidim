# frozen_string_literal: true

module Decidim
  module Core

    module CategorizableInterface
      include GraphQL::Schema::Interface
      # name "CategorizableInterface"
      # description "An interface that can be used in categorizable objects."

      field :category, Decidim::Core::CategoryType, null: false, description: "The object's category"
    end
  end
end
