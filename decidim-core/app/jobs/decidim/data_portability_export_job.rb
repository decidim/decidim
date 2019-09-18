# frozen_string_literal: true

module Decidim
  class DataPortabilityExportJob < ApplicationJob
    queue_as :default

    def perform(user, format)
      objects = Decidim::DataPortabilitySerializers.data_entities
      export_data = []
      export_images = []

      objects.each do |object|
        klass = Object.const_get(object)
        export_data << [klass.model_name.name.parameterize.pluralize, Decidim::Exporters.find_exporter(format).new(klass.user_collection(user), klass.export_serializer).export]
        export_images << [klass.model_name.name.parameterize.pluralize, klass.data_portability_images(user).flatten] unless klass.data_portability_images(user).nil?
      end

      file_zipper = Decidim::DataPortabilityFileZipper.new(user, export_data, export_images)
      file_zipper.make_zip!
      DataPortabilityUploader.new.store!(File.open(file_zipper.tmp_path, "rb"))
      ExportMailer.data_portability_export(user, file_zipper.token).deliver_later
    end
  end
end
