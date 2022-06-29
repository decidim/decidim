# frozen_string_literal: true

require "active_support/core_ext/module/delegation"
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

    def run(command, out: $stdout)
      interpolated_in_folder(command) do |cmd|
        self.class.run(cmd, out: out)
      end
    end

    def capture(command, env: {}, with_stderr: true)
      interpolated_in_folder(command) do |cmd|
        self.class.capture(cmd, env: env, with_stderr: with_stderr)
      end
    end

    def replace_gem_version
      Dir.chdir(@dir) do
        replace_file(
          "lib/#{name.tr("-", "/")}/version.rb",
          /def self\.version(\s*)"[^"]*"/,
          "def self.version\\1\"#{version}\""
        )
      end
    end

    def replace_package_version
      Dir.chdir(@dir) do
        replace_file(
          "package.json",
          /^  "version": "[^"]*"/,
          "  \"version\": \"#{semver_friendly_version(version)}\""
        )
      end
    end

    def short_name
      name.gsub(/decidim-/, "")
    end

    class << self
      def capture(cmd, env: {}, with_stderr: true)
        return Open3.capture2e(env, cmd) if with_stderr

        Open3.capture2(env, cmd)
      end

      def run(cmd, out: $stdout)
        system(cmd, out: out)
      end

      def test_participatory_space
        new("decidim-#{PARTICIPATORY_SPACES.sample}").run("rake")
      end

      def test_component
        new("decidim-#{COMPONENTS.sample}").run("rake")
      end

      def replace_versions
        all_dirs do |dir|
          new(dir).replace_gem_version
        end

        package_dirs do |dir|
          new(dir).replace_package_version
        end
      end

      def install_all(out: $stdout)
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

      def uninstall_all(out: $stdout)
        run_all(
          "gem uninstall %name -v %version --executables --force",
          out: out
        )

        new(root).run(
          "rm decidim-*.gem",
          out: out
        )
      end

      def run_all(command, out: $stdout, include_root: true)
        all_dirs(include_root: include_root) do |dir|
          status = run_at(dir, command, out: out)

          break if !status && fail_fast?
        end
      end

      def run_packages(command, out: $stdout)
        package_dirs do |dir|
          status = run_at(dir, command, out: out)

          break if !status && fail_fast?
        end
      end

      def run_at(dir, command, out: $stdout)
        attempts = 0
        until (status = new(dir).run(command, out: out))
          attempts += 1

          break if attempts > Decidim::GemManager.retry_times
        end

        status
      end

      def version
        @version ||= File.read(version_file).strip
      end

      def replace_file(name, regexp, replacement)
        new_content = File.read(name).gsub(regexp, replacement)

        File.write(name, new_content)
      end

      def all_dirs(include_root: true)
        dirs = plugins
        dirs << "./" if include_root

        dirs.each { |dir| yield(dir) }
      end

      def package_dirs
        dirs = Dir.glob("#{root}/packages/*")

        dirs.each { |dir| yield(dir) }
      end

      def plugins
        Dir.glob("#{root}/decidim-*/")
      end

      def semver_friendly_version(a_version)
        a_version.gsub(/\.pre/, "-pre").gsub(/\.dev/, "-dev").gsub(/.rc(\d*)/, "-rc\\1")
      end

      def fail_fast?
        ENV.fetch("FAIL_FAST", nil) != "false"
      end

      def retry_times
        ENV.fetch("RETRY_TIMES", 10).to_i
      end

      private

      def root
        File.expand_path(File.join("..", ".."), __dir__)
      end

      def version_file
        File.join(root, ".decidim-version")
      end
    end

    private

    delegate :plugins, :replace_file, :semver_friendly_version, :version, to: :class

    def interpolated_in_folder(command)
      Dir.chdir(@dir) do
        yield command.gsub("%version", version).gsub("%name", name)
      end
    end

    def folder_name
      File.basename(@dir)
    end

    def name
      plugins.map { |name| File.expand_path(name) }.include?(@dir) ? folder_name : "decidim"
    end
  end
end
