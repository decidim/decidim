# frozen_string_literal: true

require "open3"

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
  class GemManager
    PARTICIPATORY_SPACES = %w(
      participatory_processes
      assemblies
      consultations
    ).freeze

    COMPONENTS = %w(
      accountability
      budgets
      debates
      meetings
      pages
      proposals
      surveys
      sortitions
      blogs
    ).freeze

    def initialize(dir)
      @dir = File.expand_path(dir)
    end

    def run(command, out: STDOUT)
      interpolated_in_folder(command) do |cmd|
        self.class.run(cmd, out: out)
      end
    end

    def capture(command)
      interpolated_in_folder(command) do |cmd|
        self.class.capture(cmd)
      end
    end

    def replace_version
      Dir.chdir(@dir) do
        self.class.replace_file(
          "lib/#{name.tr("-", "/")}/version.rb",
          /def self\.version(\s*)"[^"]*"/,
          "def self.version\\1\"#{version}\""
        )
      end
    end

    def short_name
      name.gsub(/decidim-/, "")
    end

    class << self
      def capture(cmd, env: {})
        output, status = Open3.capture2e(env, cmd)

        abort unless continue?(status.success?)

        [output, status]
      end

      def run(cmd, out: STDOUT)
        status = system(cmd, out: out)

        abort unless continue?(status == true)

        status
      end

      def continue?(status)
        status || ENV["FAIL_FAST"] == "false"
      end

      def test_participatory_space
        new("decidim-#{PARTICIPATORY_SPACES.sample}").run("rake")
      end

      def test_component
        new("decidim-#{COMPONENTS.sample}").run("rake")
      end

      def replace_versions
        replace_file(
          "package.json",
          /^  "version": "[^"]*"/,
          "  \"version\": \"#{semver_friendly_version}\""
        )

        all_dirs do |dir|
          new(dir).replace_version
        end
      end

      def run_all(command, out: STDOUT, include_root: true)
        all_dirs(include_root: include_root) do |dir|
          new(dir).run(command, out: out)
        end
      end

      def version
        @version ||= File.read(version_file).strip
      end

      def replace_file(name, regexp, replacement)
        new_content = File.read(name).gsub(regexp, replacement)

        File.open(name, "w") { |f| f.write(new_content) }
      end

      def all_dirs(include_root: true)
        root = File.expand_path(File.join("..", ".."), __dir__)

        glob = "#{root}/#{include_root ? "{decidim-*,.}" : "decidim-*"}"

        Dir.glob(glob)
           .select { |f| File.directory?(f) }
           .each { |dir| yield(dir) }
      end

      private

      def semver_friendly_version
        version.gsub(/\.pre/, "-pre").gsub(/\.dev/, "-dev")
      end

      def version_file
        File.expand_path(File.join("..", "..", ".decidim-version"), __dir__)
      end
    end

    private

    def interpolated_in_folder(command)
      Dir.chdir(@dir) do
        yield command.gsub("%version", version).gsub("%name", name)
      end
    end

    def folder_name
      File.basename(@dir)
    end

    def name
      folder_name.match?("decidim") ? folder_name : "decidim"
    end

    def version
      self.class.version
    end
  end
end
