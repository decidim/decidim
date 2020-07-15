# frozen_string_literal: true

module Decidim
  module Core
    # This interface represents an amendable object.
    AmendableInterface = GraphQL::InterfaceType.define do
      name "AmendableInterface"
      description "An interface that can be used in objects with amendments"

      field :amendments, !types[Decidim::Core::AmendmentType] do
        description "This object's amendments"
        resolve lambda { |obj, _args, ctx|
          obj.visible_amendments_for(ctx[:current_user])
        }
      end
    end
  end
end
