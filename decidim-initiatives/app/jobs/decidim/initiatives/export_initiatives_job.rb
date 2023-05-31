# frozen_string_literal: true

module Decidim
  module Initiatives
    class ExportInitiativesJob < ApplicationJob
      queue_as :exports

      def perform(user, organization, format, collection_ids = nil)
        export_data = Decidim::Exporters.find_exporter(format).new(
          collection_to_export(collection_ids, organization),
          serializer
        ).export

        ExportMailer.export(user, "initiatives", export_data).deliver_now
      end

      private

      def collection_to_export(ids, organization)
        collection = Decidim::Initiative.where(organization:)

        collection = collection.where(id: ids) if ids.present?

        collection.order(id: :asc)
      end

      def serializer
        Decidim::Initiatives::InitiativeSerializer
      end
    end
  end
end
