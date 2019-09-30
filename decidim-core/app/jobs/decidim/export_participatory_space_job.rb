# frozen_string_literal: true

module Decidim
  class ExportParticipatorySpaceJob < ApplicationJob
    queue_as :default

    def perform(user, participatory_space, name, format)
      export_manifest = participatory_space.manifest.export_manifests.find do |manifest|
        manifest.name == name.to_sym
      end

      collection = export_manifest.collection.call(participatory_space)
      serializer = export_manifest.serializer

      export_data = Decidim::Exporters.find_exporter(format).new(collection, serializer).export

      Decidim::ExportMailer.export(user, name, export_data).deliver_now
    end
  end
end
