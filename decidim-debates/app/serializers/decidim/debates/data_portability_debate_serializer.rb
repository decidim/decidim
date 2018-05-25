# frozen_string_literal: true

module Decidim
  module Debates
    class DataPortabilityDebateSerializer < Decidim::Exporters::Serializer
      # Serializes a Debate for data portability
      def serialize
        {
          id: resource.id,
          title: resource.title,
          description: resource.description,
          instructions: resource.instructions,
          start_time: resource.start_time,
          end_time: resource.end_time,
          information_updates: resource.information_updates,
          reference: resource.reference,
          component: resource.component.name
        }
      end
    end
  end
end
