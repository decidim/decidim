# frozen_string_literal: true

module Decidim
  class OpenDataExporter
    attr_reader :organization, :path

    EXPORTS = [
      {
        manifest_name: :proposals,
        export_name: "proposals"
      },
      {
        manifest_name: :accountability,
        export_name: "results"
      }
    ].freeze

    def initialize(organization, path)
      @organization = organization
      @path = path
    end

    def export
      File.open(path, "wb") { |file| file.write(data) }
    end

    private

    def data
      buffer = Zip::OutputStream.write_buffer do |out|
        EXPORTS.each do |options|
          manifest_export_data = data_for(options[:manifest_name], options[:export_name])
          out.put_next_entry("#{organization.host}-open-data-#{options[:export_name]}.csv")
          out.write manifest_export_data.read
        end
      end

      buffer.string
    end

    def data_for(manifest_name, export_name)
      export_manifest = Decidim.find_component_manifest(manifest_name).export_manifests.find do |manifest|
        manifest.name.to_s == export_name
      end

      collection = components.where(manifest_name: manifest_name).find_each.flat_map do |component|
        export_manifest.collection.call(component)
      end

      Decidim::Exporters::CSV.new(collection, export_manifest.serializer).export
    end

    def components
      @components ||= organization.published_components
    end
  end
end
