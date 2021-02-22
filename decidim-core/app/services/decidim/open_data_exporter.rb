# frozen_string_literal: true

require "zip"

module Decidim
  # Public: It generates a ZIP file with Open Data CSV files ready
  # to be uploaded somewhere so users can download an organization
  # data.
  class OpenDataExporter
    attr_reader :organization, :path

    # Public: Initializes the class.
    #
    # organization - The Organization to export the data from.
    # path         - The String path where to write the zip file.
    def initialize(organization, path)
      @organization = organization
      @path = File.expand_path path
    end

    def export
      dirname = File.dirname(path)
      FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
      File.open(path, "wb") { |file| file.write(data) }
    end

    private

    def data
      buffer = Zip::OutputStream.write_buffer do |out|
        open_data_manifests.each do |export_manifest|
          csv_data = data_for(export_manifest)
          out.put_next_entry("#{organization.host}-open-data-#{export_manifest.name}.csv")
          out.write csv_data.read
        end
      end

      buffer.string
    end

    def data_for(export_manifest)
      collection = components.where(manifest_name: export_manifest.manifest.name).find_each.flat_map do |component|
        export_manifest.collection.call(component)
      end

      Decidim::Exporters::CSV.new(collection, export_manifest.serializer).export
    end

    def open_data_manifests
      @open_data_manifests ||= Decidim.component_manifests
                                      .flat_map(&:export_manifests)
                                      .select(&:include_in_open_data?)
                                      .concat(Decidim.participatory_space_manifests
          .flat_map(&:export_manifests)
          .select(&:include_in_open_data?))
    end

    def components
      @components ||= organization.published_components
    end

    # def participatory_spaces
    #   # Decidim.participatory_space_manifests.flat_map do |manifest|
    #   #   manifest.participatory_spaces.call(self).public_spaces
    #   # end
    #   @participatory_spaces ||= organization.public_participatory_spaces
    # end
  end
end
