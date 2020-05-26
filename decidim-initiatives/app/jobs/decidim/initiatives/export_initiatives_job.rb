# frozen_string_literal: true

module Decidim
  module Initiatives
    class ExportInitiativesJob < ApplicationJob
      queue_as :default

      def perform(user, format)
        export_data = Decidim::Exporters.find_exporter(format).new(collection, serializer).export

        ExportMailer.export(user, "initiatives", export_data).deliver_now
      end

      private

      def collection
        Decidim::Initiative.all
      end

      def serializer
        Decidim::Initiatives::InitiativeSerializer
      end
    end
  end
end
