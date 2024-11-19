# frozen_string_literal: true

module Decidim
  module Initiatives
    class ExportInitiativesJob < ApplicationJob
      include Decidim::PrivateDownloadHelper

      queue_as :exports

      def perform(user, organization, format, collection_ids = nil)
        export_data = Decidim::Exporters.find_exporter(format).new(
          collection_to_export(collection_ids, organization),
          serializer
        ).export

        private_export = attach_archive(export_data, "initiatives", user)

        ExportMailer.export(user, private_export).deliver_later
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
