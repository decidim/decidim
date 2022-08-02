# frozen_string_literal: true

require "zip"

module Decidim
  # Public: It generates a ZIP file with Open Data CSV files ready
  # to be uploaded somewhere so users can download an organization
  # data.
  class OpenDataExporter
    FILE_NAME_PATTERN = "%{host}-open-data-%{entity}.csv"

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
      File.binwrite(path, data)
    end

    private

    def data
      buffer = Zip::OutputStream.write_buffer do |out|
        open_data_component_manifests.each do |manifest|
          add_file_to_output(out, format(FILE_NAME_PATTERN, { host: organization.host, entity: manifest.name }), data_for_component(manifest))
        end
        open_data_participatory_space_manifests.each do |manifest|
          add_file_to_output(out, format(FILE_NAME_PATTERN, { host: organization.host, entity: manifest.name }), data_for_participatory_space(manifest))
        end
      end

      buffer.string
    end

    def data_for_component(export_manifest, col_sep = Decidim.default_csv_col_sep)
      headers = []
      collection = []
      ActiveRecord::Base.uncached do
        components.where(manifest_name: export_manifest.manifest.name).find_each do |component|
          export_manifest.collection.call(component).find_in_batches(batch_size: 100) do |batch|
            exporter = Decidim::Exporters::CSV.new(batch, export_manifest.serializer)
            headers.push(*exporter.headers)
            exported = exporter.export

            tmpfile = Tempfile.new("#{export_manifest.name}-#{component.id}-")
            tmpfile.write(exported.read)
            # Do not delete the file when the reference is deleted
            ObjectSpace.undefine_finalizer(tmpfile)
            tmpfile.close

            collection.push(tmpfile.path)
          end
        end
      end

      headers.uniq!

      data = CSV.generate_line(headers, col_sep:)
      collection.each do |content|
        CSV.foreach(content, headers: true, col_sep:) do |row|
          data << CSV.generate_line(row.values_at(*headers), col_sep:)
        end
        File.unlink(content)
      end
      Decidim::Exporters::ExportData.new(data, "csv")
    end

    def data_for_participatory_space(export_manifest)
      collection = participatory_spaces.filter { |space| space.manifest.name == export_manifest.manifest.name }.flat_map do |participatory_space|
        export_manifest.collection.call(participatory_space)
      end

      Decidim::Exporters::CSV.new(collection, export_manifest.serializer).export
    end

    def add_file_to_output(output, file_name, data)
      output.put_next_entry(file_name)
      output.write data.read
    end

    def open_data_component_manifests
      @open_data_component_manifests ||= Decidim.component_manifests
                                                .flat_map(&:export_manifests)
                                                .select(&:include_in_open_data?)
    end

    def open_data_participatory_space_manifests
      @open_data_participatory_space_manifests ||= Decidim.participatory_space_manifests
                                                          .flat_map(&:export_manifests)
                                                          .select(&:include_in_open_data?)
    end

    def components
      @components ||= organization.published_components
    end

    def participatory_spaces
      @participatory_spaces ||= organization.public_participatory_spaces
    end
  end
end
