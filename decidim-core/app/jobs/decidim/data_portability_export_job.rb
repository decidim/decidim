# frozen_string_literal: true

module Decidim
  class DataPortabilityExportJob < ApplicationJob
    queue_as :default

    def perform(user, format)
      objects = Decidim::DataPortabilitySerializers.data_entities
      export_data = []

      objects.each do |object|
        klass = Object.const_get(object)
        export_data << [klass.model_name.name.parameterize.pluralize, Decidim::Exporters.find_exporter(format).new(klass.user_collection(user), klass.export_serializer).export]
      end

      ExportMailer.data_portability_export(user, export_data).deliver_now
    end
  end
end
