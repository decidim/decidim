# frozen_string_literal: true

module Decidim
  class DataPortabilityExportJob < ApplicationJob
    queue_as :default

    def perform(user, name, format)

      # export_manifest = component.manifest.export_manifests.find do |manifest|
      #   manifest.name == name.to_sym
      # end

      # collection = export_manifest.collection.call(component)
      # serializer = export_manifest.serializer

      collection = Decidim::Proposals::Proposal.where(decidim_author_id: user.id)
      serializer = Decidim::Exporters::Serializer

      export_data = Decidim::Exporters.find_exporter(format).new(collection, serializer).export

      ExportMailer.export(user, name, export_data).deliver_now
    end
  end
end
