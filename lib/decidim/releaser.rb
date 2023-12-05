# frozen_string_literal: true

require "open3"
require "decidim/github_manager/poster"

module Decidim
  class Releaser
    class InvalidMetadataError < StandardError; end

    class InvalidBranchError < StandardError; end

    class InvalidVersionTypeError < StandardError; end

    DECIDIM_VERSION_FILE = ".decidim-version"

    # @param token [String] token for GitHub authentication
    # @param version_type [String] The kind of release that you want to prepare. Supported values: rc, minor, patch
    # @param working_dir [String] current working directory. Useful for testing purposes
    # @param exit_with_unstaged_changes [Boolean] wheter we should exit cowardly if there is any unstaged change
    def initialize(token:, version_type:, working_dir: Dir.pwd, exit_with_unstaged_changes: false)
      @token = token
      @version_type = version_type
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

        check_tests

        generate_changelog

        run("git checkout -b chore/prepare/#{version_number}")
        run("git commit -a -m 'Prepare #{version_number} release'")
        run("git push origin chore/prepare/#{version_number}")

        create_pull_request
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
    # @raise [InvalidBranchError]
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
    # @todo support the "minor" type version
    #
    # @return [String] the version number
    def version_number
      @version_number ||= case @version_type
                          when "rc"
                            next_version_number_for_release_candidate(old_version_number)
                          when "patch"
                            next_version_number_for_patch_release(old_version_number)
                          else
                            raise InvalidVersionTypeError, "This is not a supported version type"
                          end
    end

    def parsed_version_number(version_number)
      /(?<major>\d+)\.(?<minor>\d+)\.(?<patch>\d+)/ =~ version_number

      { major: major.to_i, minor: minor.to_i, patch: patch.to_i }
    end

    # Given a version number, returns the next release candidate
    #
    # If the current version number is `dev`, then we return the `rc1` version
    # If the current version number is `rc`, then we return the next `rc` version
    # Else, it means is a `minor` or `patch` version. On those cases we raise an Exception, as releases candidates should
    # be only done from a `dev` or a `rc` version.
    #
    # @raise [InvalidVersionTypeError]
    #
    # @param current_version_number [String] - The version number of the current version
    #
    # @return [String] - the new version number
    def next_version_number_for_release_candidate(current_version_number)
      if current_version_number.include? "dev"
        parsed_version_number(current_version_number) => { major:, minor:, patch: }
        new_version_number = "#{major}.#{minor}.#{patch}.rc1"
      elsif current_version_number.include? "rc"
        new_rc_number = current_version_number.match(/rc(\d)/)[1].to_i + 1
        new_version_number = current_version_number.gsub(/rc\d/, "rc#{new_rc_number}")
      else
        error_message = <<-EOMESSAGE
          Trying to do a release candidate version from patch release. Bailing out.
          You need to do a release candidate from a `dev` or from another `rc` version
        EOMESSAGE
        raise InvalidVersionTypeError, error_message
      end

      new_version_number
    end

    # Given a version number, returns the next patch release
    #
    # If the current version number is `dev`, then we raise an Exception, as you need to first do a release candidate.
    # If the current version number is `rc`, then we return the `0` patch version
    # Else, it means is a `patch` version, so we return the next patch version
    #
    # @raise [InvalidVersionTypeError]
    #
    # @param current_version_number [String] - The version number of the current version
    #
    # @return [String] - the new version number
    def next_version_number_for_patch_release(current_version_number)
      parsed_version_number(current_version_number) => { major:, minor:, patch: }

      if current_version_number.include? "dev"
        error_message = <<-EOMESSAGE
          Trying to do a patch version from dev release. Bailing out.
          You need to do first a release candidate.
        EOMESSAGE
        raise InvalidVersionTypeError, error_message
      elsif current_version_number.include? "rc"
        new_version_number = "#{major}.#{minor}.0"
      else
        new_version_number = "#{major}.#{minor}.#{patch.to_i + 1}"
      end

      new_version_number
    end

    # The version number from the file
    #
    # @return [String] the version number
    def old_version_number
      File.read(DECIDIM_VERSION_FILE).strip
    end

    # Run the tests and if fails restore the changes using git and exit with an error
    #
    # @return [void]
    def check_tests
      # rubocop:disable Rails/Output
      puts "Running specs"
      output, status = capture("bin/rspec")

      unless status.sucess?
        run("git restore .")
        puts output
        exit_with_errors("Tests execution failed. Fix the errors and run again.")
      end
      # rubocop:enable Rails/Output
    end

    # Generates the changelog taking into account the last time the version changed
    #
    # @return [void]
    def generate_changelog
      sha_version = capture("git log -n 1 --pretty=format:%h -- .decidim-version")[0]
      run("bin/changelog_generator #{@token} #{sha_version}")
      temporary_changelog = File.read("./temporary_changelog.md")
      legacy_changelog = File.read("./CHANGELOG.md")
      version_changelog = "## [#{version_number}](https://github.com/decidim/decidim/tree/#{version_number})\n\n#{temporary_changelog}\n"
      changelog = legacy_changelog.gsub("# Changelog\n\n", "# Changelog\n\n#{version_changelog}")
      File.write("./CHANGELOG.md", changelog)
    end

    # Creates the pull request for bumping the version
    #
    # @return [void]
    def create_pull_request
      base_branch = release_branch
      head_branch = "chore/prepare/#{version_number}"

      params = {
        title: "Bump to v#{version_number} version",
        body: "#### :tophat: What? Why?

This PR changes the version of the #{release_branch} branch, so we can publish the release once this is approved and merged.

#### Testing

All the tests should pass, except for some generators tests, that will fail because the gems and NPM packages have not
been actually published yet (as in sent to rubygems/npm).
You will see errors such as `No matching version found for @decidim/browserslist-config@~0.xx.y` in the CI logs.

:hearts: Thank you!
        ",
        labels: ["type: internal"],
        head: head_branch,
        base: base_branch
      }
      Decidim::GithubManager::Poster.new(token: @token, params:).call
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
