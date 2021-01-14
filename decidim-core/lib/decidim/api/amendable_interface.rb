# frozen_string_literal: true

module Decidim
  module Core
    # This interface represents an amendable object.
    module AmendableInterface
      include Decidim::Api::Types::BaseInterface
      description "An interface that can be used in objects with amendments"

      field :amendments, [Decidim::Core::AmendmentType, { null: true }], description: "This object's amendments", null: false

      def amendments
        object.visible_amendments_for(context[:current_user])
      end
    end
  end
end
