# frozen_string_literal: true

module Decidim
  class ExportJob < ApplicationJob
    queue_as :default

    def perform(user, component, name, format, resource_id = nil)
      export_manifest = component.manifest.export_manifests.find do |manifest|
        manifest.name == name.to_sym
      end

      collection = export_manifest.collection.call(component, user, resource_id)
      serializer = export_manifest.serializer

      export_data = Decidim::Exporters.find_exporter(format).new(collection, serializer).export

      ExportMailer.export(user, name, export_data).deliver_now
    end
  end
end
