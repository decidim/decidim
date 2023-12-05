# frozen_string_literal: true

require "open3"
require "decidim/github_manager/poster"

module Decidim
  class Releaser
    class InvalidMetadataError < StandardError; end

    class InvalidBranchError < StandardError; end

    DECIDIM_VERSION_FILE = ".decidim-version"

    # @param token [String] token for GitHub authentication
    # @param working_dir [String] current working directory. Useful for testing purposes
    # @param exit_with_unstaged_changes [Boolean] wheter we should exit cowardly if there is any unstaged change
    def initialize(token:, working_dir: Dir.pwd, exit_with_unstaged_changes: false)
      @token = token
      @working_dir = working_dir
      @exit_with_unstaged_changes = exit_with_unstaged_changes
    end

    def call
      Dir.chdir(@working_dir) do
        exit_if_unstaged_changes if @exit_with_unstaged_changes

        run("git checkout #{release_branch}")
        run("git pull origin #{release_branch}")
        bump_decidim_version
        run("bin/rake update_versions")
        run("bin/rake bundle")
        run("npm install")
        generate_changelog

        # rubocop:disable Rails/Output
        puts "Check all the changes before making the PR"
        puts "After you finish leave the change staged and exit the shell with the `exit` command"
        system ENV.fetch("SHELL")
        # rubocop:enable Rails/Output

        run("git checkout -b chore/prepare/#{version_number}")
        run("git commit -a -m 'Prepare #{version_number} release'")
        run("git push origin chore/prepare/#{version_number}")

        # create_pull_request
      end
    end

    private

    # The git branch
    #
    # @return [String]
    def branch
      @branch ||= capture("git rev-parse --abbrev-ref HEAD")[0].strip
    end

    # Raise an error if the branch does not start with the preffix "release/"
    # or returns the branch name
    #
    # @raise [Exception]
    #
    # @return [String]
    def release_branch
      raise InvalidBranchError, "This is not a release branch, aborting" unless branch.start_with?("release/")

      branch
    end

    # Changes the decidim version in the file
    #
    # @return [void]
    def bump_decidim_version
      File.write(DECIDIM_VERSION_FILE, version_number)
    end

    # The version number for the release that we are preparing
    #
    # @return [String] the version number
    def version_number
      @version_number ||= if old_version_number.include? "rc"
                            next_version_number_for_release_candidate(old_version_number)
                          else
                            next_version_number_for_patch_release(old_version_number)
                          end
    end

    # Given a version number, returns the next release candidate
    #
    # @return [String]
    def next_version_number_for_release_candidate(version_number)
      new_rc_number = version_number.match(/rc(\d)/)[1].to_i + 1
      version_number.gsub(/rc\d/, "rc#{new_rc_number}")
    end

    # Given a version number, returns the next patch release
    #
    # @return [String]
    def next_version_number_for_patch_release(version_number)
      /(?<major>\d+)\.(?<minor>\d+)\.(?<patch>\d+)/ =~ version_number

      "#{major}.#{minor}.#{patch.to_i + 1}"
    end

    # The version number from the file
    #
    # @return [String] the version number
    def old_version_number
      File.read(DECIDIM_VERSION_FILE).strip
    end

    # Generates the changelog taking into account the last time the version changed
    #
    # @return [void]
    def generate_changelog
      sha_version = capture("git log -n 1 --pretty=format:%h -- .decidim-version")[0]
      run("bin/changelog_generator #{@token} #{sha_version}")
      temporary_changelog = File.read("./temporary_changelog.md")
      legacy_changelog = File.read("./CHANGELOG.md")
      changelog = legacy_changelog.gsub("# Changelog\r", "# Changelog\r #{temporary_changelog}")
      File.write("./CHANGELOG.md", changelog)
    end

    # Creates the pull request for bumping the version
    #
    # @return [void]
    def create_pull_request
      base_branch = release_branch
      head_branch = "chore/prepare/#{version_number}"

      run("git branch #{head_branch}")
      run("git swtich --quiet #{head_branch}")

      params = {
        title: "Bump to #{version_number} version",
        body: "#### :tophat: What? Why?

This PR changes the version of the #{release_branch} branch, so we can publish the release once this is approved and merged.

#### Testing

Everything should be green.

:hearts: Thank you!
        ",
        labels: ["type: internal"],
        head: head_branch,
        base: base_branch
      }
      Decidim::GitHubManager::Poster.new(token: @token, params:)
    end

    # Captures to output of a command
    #
    # @return [Array<String, Process::Status>] The stdout and stderr of the command and its status (aka error code)
    def capture(cmd, env: {})
      Open3.capture2e(env, cmd)
    end

    # Runs a command
    #
    # @return [void]
    def run(cmd, out: $stdout)
      system(cmd, out:)
    end

    # Exit the script execution if there are any unstaged changes
    #
    # @return [void]
    def exit_if_unstaged_changes
      return if `git diff`.empty?

      error_message = <<-EOERROR
  There are changes not staged in your project.
  Please commit your changes or stash them.
      EOERROR
      exit_with_errors(error_message)
    end

    # Exit the script execution with a message
    #
    # @return [void]
    def exit_with_errors(message)
      # rubocop:disable Rails/Output, Rails/Exit
      puts message
      exit 1
      # rubocop:enable Rails/Output, Rails/Exit
    end
  end
end
