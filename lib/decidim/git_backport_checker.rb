# frozen_string_literal: true

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
    # @param days_to_check_from [Integer] the number of days from when we will start the check
    def initialize(token:, days_to_check_from:)
      @token = token
      @days_to_check_from = days_to_check_from
    end

    def call
      @report = by_label(
        label: "type: fix",
        exclude_labels: ["backport", "no-backport"],
        days_to_check_from: @days_to_check_from
      ).map do |pull_request|
        {
          id: pull_request[:id],
          title: pull_request[:title],
          related_issues: related_issues(pull_request[:id])
        }
      end
    end

    def csv_report = Decidim::BackportsReporter::CSVReport.new(report: @report).call

    def cli_report = Decidim::BackportsReporter::CLIReport.new(report: @report).call

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
