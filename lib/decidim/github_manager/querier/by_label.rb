# frozen_string_literal: true

require "active_support/core_ext/time/zones"
require_relative "base"

module Decidim
  module GithubManager
    module Querier
      # Makes a GET request for the list of Issues or Pull Requests in GitHub
      # by a label that were created in the last 90 days and that are closed.
      #
      # @param token [String] token for GitHub authentication
      # @param days_to_check_from [Integer] the number of days from when we will start the check
      # @param label [String] the label that we want to search by
      # @param exclude_labels [Array] the labels that we want to exclude in the search
      #
      # @see https://docs.github.com/en/rest/issues/issues#list-repository-issues GitHub API documentation
      class ByLabel < Decidim::GithubManager::Querier::Base
        def initialize(token:, days_to_check_from: 90, label: "type: fix", exclude_labels: ["backport", "no-backport"])
          @label = label
          @exclude_labels = exclude_labels
          @token = token
          @days_to_check_from = days_to_check_from
        end

        # Makes the GET request and parses the response of an Issue or Pull Request in GitHub
        #
        # @return [Hash]
        def call
          parse json_response
        end

        private

        attr_reader :label, :exclude_labels, :days_to_check_from

        def headers
          Time.zone = "UTC"

          {
            labels: label,
            state: "closed",
            per_page: 100,
            since: (Time.zone.today - days_to_check_from).iso8601
          }
        end

        def uri = "https://api.github.com/repos/decidim/decidim/issues"

        # Parses the response of an Issue or Pull Request in GitHub
        #
        # @return [Hash]
        def parse(metadata)
          metadata.map do |item|
            next if has_any_of_excluded_labels?(item)
            next unless merged?(item)

            {
              id: item["number"],
              title: item["title"]
            }
          end.compact
        end

        def has_any_of_excluded_labels?(item)
          item["labels"].map { |label| label.map { |_key, val| exclude_labels.include?(val) } }.flatten.any? true
        end

        def merged?(item)
          Date.parse(item["pull_request"]["merged_at"]).present?
        rescue TypeError, Date::Error
          false
        end
      end
    end
  end
end
