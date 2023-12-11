# frozen_string_literal: true

require "ruby-progressbar"

require_relative "github_manager/querier/by_label"
require_relative "github_manager/querier/related_issues"
require_relative "backports_reporter/csv_report"
require_relative "backports_reporter/cli_report"

module Decidim
  # Extracts the status of the Pull Requests on the decidim repository
  # with the label "type: fix" and shows the status of the related Pull Requests,
  # so we can check which PRs have pending backports
  class GitBackportChecker
    # @param token [String] token for GitHub authentication
    # @param days_to_check_from [Integer] the number of days since the pull requests were merged from when we will start the check
    # @param last_version_number [String] the version number of the last release that we want to make the backport to
    def initialize(token:, days_to_check_from:, last_version_number:)
      @token = token
      @days_to_check_from = days_to_check_from
      @last_version_number = last_version_number
    end

    def call
      pull_requests_with_labels = by_label(
        label: "type: fix",
        exclude_labels: ["backport", "no-backport"],
        days_to_check_from: @days_to_check_from
      )

      progress_bar = ProgressBar.create(title: "PRs", total: pull_requests_with_labels.count)
      @report = []

      pull_requests_with_labels.each do |pull_request|
        progress_bar.increment

        @report << {
          id: pull_request[:id],
          title: pull_request[:title],
          related_issues: related_issues(pull_request[:id])
        }
      end
    end

    def csv_report
      Decidim::BackportsReporter::CSVReport.new(
        report: @report,
        last_version_number: @last_version_number
      ).call
    end

    def cli_report
      Decidim::BackportsReporter::CLIReport.new(
        report: @report,
        last_version_number: @last_version_number
      ).call
    end

    private

    attr_reader :token

    def by_label(label:, exclude_labels:, days_to_check_from:)
      Decidim::GithubManager::Querier::ByLabel.new(
        token:,
        label:,
        exclude_labels:,
        days_to_check_from:
      ).call
    end

    def related_issues(issue_id)
      Decidim::GithubManager::Querier::RelatedIssues.new(
        token:,
        issue_id:
      ).call
    end
  end
end
