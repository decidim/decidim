# frozen_string_literal: true

module Decidim
  module Meetings
    # This interface represents a categorizable object.
    ServicesInterface = GraphQL::InterfaceType.define do
      name "ServicesInterface"
      description "An interface that can be used with services."

      field :services, !types[ServiceType], "The object's services" do
        resolve ->(meeting, _args, _ctx) {
          return [] unless meeting.services.respond_to? :map

          meeting.services.map { |service| OpenStruct.new(service) }
        }
      end
    end
  end
end
