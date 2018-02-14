# frozen_string_literal: true

module Decidim
  #
  # Handles a decidim components.
  #
  # Allows to perform custom operations on all modules in a given folder, or on
  # specific module folders.
  #
  # Potential operations are:
  #
  # * Running custom commands, via the `run` method, such as releasing it, or
  #   installing it locally.
  #
  # * Updating version files from the main `.decidim-version` file in the root
  #   of the repository.
  #
  class ComponentManager
    def initialize(dir)
      @dir = File.expand_path(dir)
    end

    def run(command, out: STDOUT)
      command = command.gsub("%version", version).gsub("%name", name)
      status = system(command, out: out)
      abort unless status || ENV["FAIL_FAST"] == "false"
    end

    def replace_version
      self.class.replace_file(
        "#{name}.gemspec",
        /s\.version = .+/,
        "s\.version = \"#{version}\""
      )
    end

    class << self
      def replace_versions
        replace_file(
          "package.json",
          /^  "version": "[^"]*"/,
          "  \"version\": \"#{version.gsub(/\.pre/, "-pre")}\""
        )

        in_all_dirs do |dir|
          new(dir).replace_version
        end
      end

      def run_all(command, out: STDOUT, include_root: true)
        in_all_dirs(include_root: include_root) do |dir|
          new(dir).run(command, out: out)
        end
      end

      def version
        File.read(version_file).strip
      end

      def version_file
        File.expand_path(File.join("..", "..", ".decidim-version"), __dir__)
      end

      def replace_file(name, regexp, replacement)
        new_content = File.read(name).gsub(regexp, replacement)

        File.open(name, "w") { |f| f.write(new_content) }
      end

      private

      def all_dirs(include_root: true)
        Dir.glob(include_root ? "{decidim-*,.}" : "decidim-*")
           .select { |f| File.directory?(f) }
      end

      def in_all_dirs(include_root: true)
        all_dirs(include_root: include_root).each do |dir|
          Dir.chdir(dir) { yield(dir) }
        end
      end
    end

    private

    def folder_name
      File.basename(@dir)
    end

    def name
      folder_name.match?("decidim") ? folder_name : "decidim"
    end

    def short_name
      name.gsub(/decidim-/, "")
    end

    def version
      self.class.version
    end
  end
end
