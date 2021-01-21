# frozen_string_literal: true

module Decidim
  module Core
    # This interface should be implemented by any Type that can be used as amendment
    # The only requirement is to have an ID and the Type name be the class.name + Type
    module AmendableEntityInterface
      include Decidim::Api::Types::BaseInterface
      description "An interface that can be used in objects with amendments"

      field :id, ID, "ID of this entity", null: false

      def self.resolve_type(obj, _ctx)
        "#{obj.class.name}Type".constantize
      end
    end
  end
end
