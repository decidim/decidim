# frozen_string_literal: true

module Decidim
  module Initiatives
    class InitiativeSerializer < Decidim::Initiatives::OpenDataInitiativeSerializer
      # Serializes an initiative
      def serialize
        super.merge(
          {
            components: serialize_components
          }
        )
      end
    end
  end
end
