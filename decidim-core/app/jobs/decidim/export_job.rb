# frozen_string_literal: true

module Decidim
  class ExportJob < ApplicationJob
    include Decidim::PrivateDownloadHelper

    queue_as :exports

    # rubocop:disable Metrics/ParameterLists
    def perform(user, component, name, format, resource_id = nil, filters = nil)
      export_manifest = component.manifest.export_manifests.find do |manifest|
        manifest.name == name.to_sym
      end

      collection = export_manifest.collection.call(component, user, resource_id)
      collection = collection.ransack(filters).result if collection.respond_to?(:ransack) && filters
      serializer = export_manifest.serializer

      export_data = Decidim::Exporters.find_exporter(format).new(collection, serializer).export

      private_export = attach_archive(export_data, name, user)

      ExportMailer.export(user, private_export).deliver_later
    end
    # rubocop:enable Metrics/ParameterLists
  end
end
