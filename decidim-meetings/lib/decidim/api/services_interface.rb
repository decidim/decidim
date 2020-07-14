# frozen_string_literal: true

module Decidim
  module Meetings
    # This interface represents a categorizable object.
    ServicesInterface = GraphQL::InterfaceType.define do
      name "ServicesInterface"
      description "An interface that can be used with services."

      field :services, !types[ServiceType], "The object's services"
    end
  end
end
