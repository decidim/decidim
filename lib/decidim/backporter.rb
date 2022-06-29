# frozen_string_literal: true

module Decidim
  class Backporter
    class InvalidMetadataError < StandardError; end

    def initialize(token:, pull_request_id:, version_number:, exit_with_unstaged_changes:)
      @token = token
      @pull_request_id = pull_request_id
      @version_number = version_number
      @exit_with_unstaged_changes = exit_with_unstaged_changes
    end

    def call
      metadata = pull_request_metadata
      raise InvalidMetadataError unless metadata

      make_cherrypick_and_branch(metadata)
      create_pull_request(metadata)
      Decidim::GitBackportManager.checkout_develop
    end

    private

    attr_reader :token, :pull_request_id, :version_number, :exit_with_unstaged_changes

    def pull_request_metadata
      Decidim::GithubManager::Querier.new(
        token: token,
        issue_id: pull_request_id
      ).call
    end

    def make_cherrypick_and_branch(metadata)
      Decidim::GitBackportManager.new(
        pull_request_id: pull_request_id,
        release_branch: release_branch,
        backport_branch: backport_branch(metadata[:title]),
        exit_with_unstaged_changes: exit_with_unstaged_changes
      ).call
    end

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

    def release_branch
      "release/#{version_number}-stable"
    end

    def backport_branch(pull_request_title)
      "backport/#{slugify(pull_request_title).slice!(0, 30)}-#{pull_request_id}"
    end

    def slugify(string)
      string.downcase.strip.gsub(" ", "-").gsub(/[^\w-]/, "")
    end
  end
end
