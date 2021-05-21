# frozen_string_literal: true

module Decidim
  module Initiatives
    class ExportInitiativesJob < ApplicationJob
      queue_as :exports

      def perform(user, format, collection_ids = nil)
        export_data = Decidim::Exporters.find_exporter(format).new(collection_to_export(collection_ids), serializer).export

        ExportMailer.export(user, "initiatives", export_data).deliver_now
      end

      private

      def collection_to_export(ids)
        return collection if ids.nil?

        Decidim::Initiative.where(id: ids)
      end

      def collection
        Decidim::Initiative.all
      end

      def serializer
        Decidim::Initiatives::InitiativeSerializer
      end
    end
  end
end
