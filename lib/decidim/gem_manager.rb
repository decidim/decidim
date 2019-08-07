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
      conferences
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
        Open3.capture2e(env, cmd)
      end

      def run(cmd, out: STDOUT)
        system(cmd, out: out)
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

      def install_all(out: STDOUT)
        run_all(
          "gem build %name && mv %name-%version.gem ..",
          include_root: false,
          out: out
        )

        new(root).run(
          "gem build %name && gem install *.gem",
          out: out
        )
      end

      def uninstall_all(out: STDOUT)
        run_all(
          "gem uninstall %name -v %version --executables --force",
          out: out
        )

        new(root).run(
          "rm decidim-*.gem",
          out: out
        )
      end

      def run_all(command, out: STDOUT, include_root: true)
        all_dirs(include_root: include_root) do |dir|
          status = new(dir).run(command, out: out)

          break unless status || ENV["FAIL_FAST"] == "false"
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
        dirs = plugins
        dirs << "./" if include_root

        dirs.each { |dir| yield(dir) }
      end

      def plugins
        Dir.glob("#{root}/decidim-*/")
      end

      private

      def root
        File.expand_path(File.join("..", ".."), __dir__)
      end

      def semver_friendly_version
        version.gsub(/\.pre/, "-pre").gsub(/\.dev/, "-dev")
      end

      def version_file
        File.join(root, ".decidim-version")
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
      self.class.plugins.map { |name| File.expand_path(name) }.include?(@dir) ? folder_name : "decidim"
    end

    def version
      self.class.version
    end
  end
end
