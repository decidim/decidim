# frozen_string_literal: true

module Decidim
  class DataPortabilityExportJob < ApplicationJob
    queue_as :default

    def perform(user, name, format)
      objects = ActiveRecord::Base.descendants.select{|c| c.included_modules.include?(Decidim::DataPortability)}

      export_data = []
      objects.each do |object|
        export_data << [object.model_name.human.pluralize,  Decidim::Exporters.find_exporter(format).new(object.user_collection(user), object.export_serializer).export ]
      end

      ExportMailer.data_portability_export(user, name, export_data).deliver_now
    end
  end
end
