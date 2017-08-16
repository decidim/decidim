# frozen_string_literal: true

module Decidim
  class ExportJob < ApplicationJob
    queue_as :default

    def perform(user, feature, name, format)
      export_manifest = feature.manifest.export_manifests.find do |manifest|
        manifest.name == name.to_sym
      end

      collection = export_manifest.collection.call(feature)
      serializer = export_manifest.serializer

      export_data = Decidim::Exporters.find_exporter(format).new(collection, serializer).export

      ExportMailer.export(user, name, export_data).deliver_now
    end
  end
end
