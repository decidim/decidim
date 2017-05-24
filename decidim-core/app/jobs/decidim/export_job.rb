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

      export_data = Decidim::Exporters.const_get(format.upcase).new(collection, serializer).export

      name = "#{name}-#{I18n.localize(DateTime.now.to_date, format: :default)}-#{Time.now.seconds_since_midnight.to_i}"

      ExportMailer.export(user, name, export_data).deliver_now
    end
  end
end
