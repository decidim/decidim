# frozen_string_literal: true

module Decidim
  module Initiatives
    # This interface represents a commentable object.

    module InitiativeTypeInterface
      include Decidim::Api::Types::BaseInterface
      description "An interface that can be used in Initiative objects."

      field :initiative_type, Decidim::Initiatives::InitiativeApiType, "The object's initiative type", null: true, method: :type
    end
  end
end
