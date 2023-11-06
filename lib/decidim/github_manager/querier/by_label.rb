# frozen_string_literal: true

require "active_support/core_ext/time/zones"
require_relative "base"

module Decidim
  module GithubManager
    module Querier
      # Makes a GET request for the list of Issues or Pull Requests in GitHub.
      # They must comply the following conditions:
      # * To be merged in the period between the days to check from and today. (90 days by default)
      # * To have the label that we are querying ("type: fix" by default)
      # * To not have any of the excluded labels (["backport", "no-backport"] by default)
      # * To have been merged
      #
      # @param token [String] token for GitHub authentication
      # @param days_to_check_from [Integer] the number of days since the pull requests were merged from when we will start the check
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
          parse json_response("https://api.github.com/repos/decidim/decidim/issues")
        end

        private

        attr_reader :label, :exclude_labels, :days_to_check_from

        def headers
          Time.zone = "UTC"

          {
            labels: label,
            state: "closed",
            per_page: 100,
            since: since.iso8601
          }
        end

        def since
          Time.zone.today - days_to_check_from
        end

        # Parses the response of an Issue or Pull Request in GitHub
        #
        # @return [Hash]
        def parse(metadata)
          metadata.map do |item|
            next if has_any_of_excluded_labels?(item)
            next unless merged?(item)
            next unless merged_in_date_range?(item)

            {
              id: item["number"],
              title: item["title"]
            }
          end.compact
        end

        def has_any_of_excluded_labels?(item)
          item["labels"].map { |label| label.map { |_key, val| exclude_labels.include?(val) } }.flatten.any? true
        end

        def merged_at(item)
          Date.parse(item["pull_request"]["merged_at"])
        end

        def merged?(item)
          return false if item["pull_request"].nil?

          merged_at(item).present?
        rescue TypeError, Date::Error
          false
        end

        def merged_in_date_range?(item)
          merged_at(item) > since
        end
      end
    end
  end
end
