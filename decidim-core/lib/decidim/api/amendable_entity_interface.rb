# frozen_string_literal: true

module Decidim
  module Core
    # This interface should be implemented by any Type that can be used as amendment
    # The only requirement is to have an ID and the Type name be the class.name + Type

    module AmendableEntityInterface
      include GraphQL::Schema::Interface
      # name "AmendableEntityInterface"
      description "An interface that can be used in objects with amendments"

      field :id, ID, null: false, description: "ID of this entity"

      def resolve_type(obj:, _ctx:)
        "#{obj.class.name}Type".constantize
      end
    end
  end
end
