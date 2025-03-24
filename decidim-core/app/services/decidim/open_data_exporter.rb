# frozen_string_literal: true

require "zip"

module Decidim
  # Public: It generates a ZIP file with Open Data CSV files ready
  # to be uploaded somewhere so users can download an organization
  # data.
  class OpenDataExporter
    FILE_NAME_PATTERN = "%{host}-open-data-%{entity}.csv"

    attr_reader :organization, :path, :resource, :help_definition

    include Decidim::TranslatableAttributes

    # Public: Initializes the class.
    #
    # organization - The Organization to export the data from.
    # path         - The String path where to write the zip file.
    # resource     - The String of the component or participatory space to export. If nil, it will export all.
    def initialize(organization, path, resource = nil)
      @organization = organization
      @path = File.expand_path path
      @resource = resource
      @help_definition = {}
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
        core_data_manifests.each do |manifest|
          add_file_to_output(out, format(FILE_NAME_PATTERN, { host: organization.host, entity: manifest.name }), data_for_core(manifest).read)
        end
        open_data_component_manifests.each do |manifest|
          add_file_to_output(out, format(FILE_NAME_PATTERN, { host: organization.host, entity: manifest.name }), data_for_component(manifest).read)
        end
        open_data_participatory_space_manifests.each do |manifest|
          add_file_to_output(out, format(FILE_NAME_PATTERN, { host: organization.host, entity: manifest.name }), data_for_participatory_space(manifest).read)
        end

        add_file_to_output(out, "README.md", readme)
        add_file_to_output(out, "LICENSE.md", license)
      end

      buffer.string
    end

    def data_for_core(export_manifest)
      collection = export_manifest.collection.call(organization)
      exporter = Decidim::Exporters::CSV.new(collection, export_manifest.serializer)

      get_help_definition(:core, exporter, export_manifest, collection.count) unless collection.empty?

      exporter.export
    end

    def data_for_resource(resource)
      export_manifest = (core_data_manifests + open_data_component_manifests + open_data_participatory_space_manifests)
                        .select { |manifest| manifest.name == resource.to_sym }.first

      case export_manifest.respond_to?(:manifest) && export_manifest.manifest
      when Decidim::ComponentManifest
        data_for_component(export_manifest).read
      when Decidim::ParticipatorySpaceManifest
        data_for_participatory_space(export_manifest).read
      else
        data_for_core(export_manifest).read
      end
    end

    def data_for_component(export_manifest, col_sep = Decidim.default_csv_col_sep)
      headers = []
      collection = []
      ActiveRecord::Base.uncached do
        components.where(manifest_name: export_manifest.manifest.name).unscope(:order).find_each do |component|
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

            collection_count = exported.read.split("\n").count - 1
            get_help_definition(:components, exporter, export_manifest, collection_count) unless collection.empty?
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
      collection = participatory_spaces.flat_map do |participatory_space|
        export_manifest.collection.call(participatory_space)
      end
      serializer = export_manifest.open_data_serializer.nil? ? export_manifest.serializer : export_manifest.open_data_serializer
      exporter = Decidim::Exporters::CSV.new(collection, serializer)
      get_help_definition(:spaces, exporter, export_manifest, collection.count) unless collection.empty?

      exporter.export
    end

    def get_help_definition(manifest_type, exporter, export_manifest, collection_count)
      help_definition[manifest_type] = {} if help_definition[manifest_type].nil?
      help_definition[manifest_type][export_manifest.name] = {} if help_definition[manifest_type][export_manifest.name].blank?
      help_definition[manifest_type][export_manifest.name][:headers] = {} if help_definition[manifest_type][export_manifest.name][:headers].blank?
      exporter.headers_without_locales.each do |header|
        help_definition[manifest_type][export_manifest.name][:headers][header] = I18n.t("decidim.open_data.help.#{export_manifest.name}.#{header}")
      end
      help_definition[manifest_type][export_manifest.name][:collection_count] = 0 if help_definition[manifest_type][export_manifest.name][:collection_count].nil?
      help_definition[manifest_type][export_manifest.name][:collection_count] += collection_count
    end

    def readme
      "# #{I18n.t("decidim.open_data.help.core.title", organization: translated_attribute(organization.name))}\n\n
#{I18n.t("decidim.open_data.help.core.description")}\n\n
#{I18n.t("decidim.open_data.help.core.generated_on_date", date: I18n.l(Time.current, format: :decidim_short))}\n\n
#{core_readme}
#{space_readme}
#{component_readme}
"
    end

    def core_readme
      return unless help_definition.fetch(:core, false)

      readme_file = "## #{I18n.t("decidim.open_data.help.core.main")}\n\n"
      help_definition.fetch(:core, []).each do |element, metadata|
        headers = metadata[:headers]
        readme_file << "### #{element} (#{I18n.t("decidim.open_data.help.core.resources", count: metadata[:collection_count])})\n\n"

        headers.each do |header, help_value|
          readme_file << "* #{header}: #{help_value}\n"
        end

        readme_file << "\n\n"
      end
      readme_file
    end

    def space_readme
      return unless help_definition.fetch(:spaces, false)

      readme_file = "## #{I18n.t("decidim.open_data.help.core.spaces")}\n\n"

      help_definition.fetch(:spaces, []).each do |space, metadata|
        headers = metadata[:headers]
        readme_file << "### #{space} (#{I18n.t("decidim.open_data.help.core.resources", count: metadata[:collection_count])})\n\n"

        headers.each do |header, help_value|
          readme_file << "* #{header}: #{help_value}\n"
        end

        readme_file << "\n\n"
      end
      readme_file
    end

    def component_readme
      return unless help_definition.fetch(:components, false)

      readme_file = "## #{I18n.t("decidim.open_data.help.core.components")}\n\n"

      help_definition.fetch(:components, []).each do |component, metadata|
        headers = metadata[:headers]
        readme_file << "### #{component} (#{I18n.t("decidim.open_data.help.core.resources", count: metadata[:collection_count])})\n\n"

        headers.each do |header, help_value|
          readme_file << "* #{header}: #{help_value}\n"
        end

        readme_file << "\n\n"
      end

      readme_file
    end

    def license
      link_database = "#{I18n.t("license_database_name", scope: "decidim.open_data.index.license")}: #{I18n.t("license_database_link", scope: "decidim.open_data.index.license")}"
      link_contents = "#{I18n.t("license_contents_name", scope: "decidim.open_data.index.license")}: #{I18n.t("license_contents_link", scope: "decidim.open_data.index.license")}"

      license_file = I18n.t("title", scope: "decidim.open_data.index.license")
      license_file << "\n\n"
      license_file << I18n.t("body_1_html", scope: "decidim.open_data.index.license", organization_name: translated_attribute(organization.name), link_database:, link_contents:)

      license_file
    end

    def add_file_to_output(output, file_name, string)
      output.put_next_entry(file_name)
      output.write string
    end

    def core_data_manifests
      @core_data_manifests ||= Decidim.open_data_manifests.select(&:include_in_open_data)
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
