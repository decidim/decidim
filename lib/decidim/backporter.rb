# frozen_string_literal: true

module Decidim
  class Backporter
    class InvalidMetadataError < StandardError; end

    # @param token [String] token for GitHub authentication
    # @param pull_request_id [String] the ID of the pull request that we want to backport
    # @param version_number [String] the version number of the release that we want to make the backport to
    # @param exit_with_unstaged_changes [Boolean] wheter we should exit cowardly if there is any unstaged change
    def initialize(token:, pull_request_id:, version_number:, exit_with_unstaged_changes:)
      @token = token
      @pull_request_id = pull_request_id
      @version_number = version_number
      @exit_with_unstaged_changes = exit_with_unstaged_changes
    end

    # Handles the different tasks to create a backport:
    # * Gets the metadata of a pull request on GitHub
    # * Appls thi commit to another brach and push it to the remote repository
    # * Creates the pull request on GitHub
    #
    # @raise [InvalidMetadataError] if we couldn't get the information of this pull quest
    # @return [void]
    def call
      metadata = pull_request_metadata
      raise InvalidMetadataError unless metadata

      make_cherrypick_and_branch(metadata)
      create_pull_request(metadata)
      Decidim::GitBackportManager.checkout_develop
    end

    private

    attr_reader :token, :pull_request_id, :version_number, :exit_with_unstaged_changes

    # Asks the metadata for a given issue or pull request on GitHub API
    #
    # @return [Faraday::Response] An instance that represents an HTTP response from making an HTTP request
    def pull_request_metadata
      Decidim::GithubManager::Querier.new(
        token: token,
        issue_id: pull_request_id
      ).call
    end

    # Handles all the different tasks involved on a backport with the git command line utility
    #
    # @return [void]
    def make_cherrypick_and_branch(metadata)
      Decidim::GitBackportManager.new(
        pull_request_id: pull_request_id,
        release_branch: release_branch,
        backport_branch: backport_branch(metadata[:title]),
        exit_with_unstaged_changes: exit_with_unstaged_changes
      ).call
    end

    # Creates the pull request with GitHub API
    #
    # @return [Faraday::Response] An instance that represents an HTTP response from making an HTTP request
    def create_pull_request(metadata)
      params = {
        title: "Backport '#{metadata[:title]}' to v#{version_number}",
        body: "#### :tophat: What? Why?\n\nBackport ##{pull_request_id} to v#{version_number}\n\n:hearts: Thank you!",
        labels: (metadata[:labels] << "backport"),
        head: backport_branch(metadata[:title]),
        base: release_branch
      }

      Decidim::GithubManager::Poster.new(
        token: token,
        params: params
      ).call
    end

    # Name of the release branch
    #
    # @return [String] name of the release branch
    def release_branch
      "release/#{version_number}-stable"
    end

    # Name of the backport branch
    #
    # @return [String] name of the backport branch
    def backport_branch(pull_request_title)
      "backport/#{slugify(pull_request_title).slice!(0, 30)}-#{pull_request_id}"
    end

    # Converts a string with spaces to a slug
    # It changes it to lowercase and removes spaces
    #
    # @return [String] slugged string
    def slugify(string)
      string.downcase.strip.gsub(" ", "-").gsub(/[^\w-]/, "")
    end
  end
end
