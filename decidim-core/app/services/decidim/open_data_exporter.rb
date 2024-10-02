# frozen_string_literal: true

require "zip"

module Decidim
  # Public: It generates a ZIP file with Open Data CSV files ready
  # to be uploaded somewhere so users can download an organization
  # data.
  class OpenDataExporter
    FILE_NAME_PATTERN = "%{host}-open-data-%{entity}.csv"

    attr_reader :organization, :path, :resource

    # Public: Initializes the class.
    #
    # organization - The Organization to export the data from.
    # path         - The String path where to write the zip file.
    # resource     - The String of the component or participatory space to export. If nil, it will export all.
    def initialize(organization, path, resource = nil)
      @organization = organization
      @path = File.expand_path path
      @resource = resource
    end

    def export
      dirname = File.dirname(path)
      FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
      if resource.nil?
        File.binwrite(path, data_for_all_resources)
      else
        File.write(path, data_for_resource(resource))
      end
    end

    private

    def data_for_all_resources
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

    def data_for_resource(resource)
      export_manifest = (open_data_component_manifests + open_data_participatory_space_manifests)
                        .select { |manifest| manifest.name == resource.to_sym }.first

      case export_manifest.manifest
      when Decidim::Component
        data_for_component(export_manifest).read
      when Decidim::ParticipatorySpaceManifest
        data_for_participatory_space(export_manifest).read
      end
    end

    def data_for_component(export_manifest, col_sep = Decidim.default_csv_col_sep)
      headers = []
      collection = []
      ActiveRecord::Base.uncached do
        components.where(manifest_name: export_manifest.manifest.name).find_each do |component|
          export_manifest.collection.call(component).find_in_batches(batch_size: 100) do |batch|
            serializer = export_manifest.open_data_serializer.nil? ? export_manifest.serializer : export_manifest.open_data_serializer
            exporter = Decidim::Exporters::CSV.new(batch, serializer)
            headers.push(*exporter.headers)
            exported = exporter.export
            tmpdir = Dir::Tmpname.create(export_manifest.name.to_s) do
              # just get an empty file name
            end
            filename = File.join(tmpdir, "#{component.id}.csv")
            Dir.mkdir(tmpdir)
            File.write(filename, exported.read)

            collection.push(filename)
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
      serializer = export_manifest.open_data_serializer.nil? ? export_manifest.serializer : export_manifest.open_data_serializer

      Decidim::Exporters::CSV.new(collection, serializer).export
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
