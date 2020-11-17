# frozen_string_literal: true

module Decidim
  module Core
    # This interface represents an amendable object.
    module AmendableInterface
      include GraphQL::Schema::Interface
      # name "AmendableInterface"
      description "An interface that can be used in objects with amendments"

      field :amendments, [Decidim::Core::AmendmentType], null: false, description: "This object's amendments" do
        def resolve(obj:, _args:, ctx:)
          obj.visible_amendments_for(ctx[:current_user])
        end
      end
    end
  end
end
