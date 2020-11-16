# frozen_string_literal: true

module Decidim
  module Meetings
    # This interface represents a categorizable object.
    module ServicesInterface
      include GraphQL::Schema::Interface
      # name "ServicesInterface"
      description "An interface that can be used with services."

      field :services, [ServiceType], null: false, description: "The object's services"
    end
  end
end
