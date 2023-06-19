# frozen_string_literal: true

require_relative "base"

module Decidim
  module GithubManager
    module Querier
      # Makes a GET request for the list of Issues or Pull Requests in GitHub
      # by a label that were created in the last 90 days and that are closed.
      #
      # @see https://docs.github.com/en/rest/issues/issues#list-repository-issues GitHub API documentation
      class ByLabel < Decidim::GithubManager::Querier::Base
        def initialize(label:, exclude_label:, token:)
          @label = label
          @exclude_label = exclude_label
          @token = token
        end

        # Makes the GET request and parses the response of an Issue or Pull Request in GitHub
        #
        # @return [Hash]
        def call
          parse json_response
        end

        private

        attr_reader :label, :exclude_label

        # CHANGEME: only for testing
        # DAYS_TO_CHECK_FROM = 90
        DAYS_TO_CHECK_FROM = 10

        def headers
          {
            labels: label,
            state: "closed",
            since: (Date.today - DAYS_TO_CHECK_FROM).iso8601
          }
        end

        def uri
          "https://api.github.com/repos/decidim/decidim/issues"
        end

        # Parses the response of an Issue or Pull Request in GitHub
        #
        # @return [Hash]
        def parse(metadata)
          metadata.map do |item|
            next if has_backport_label?(item)

            {
              id: item["number"],
              title: item["title"]
            }
          end.compact
        end

        def has_backport_label?(item)
          item["labels"].map { |label| label.map { |_key, val| val == exclude_label } }.flatten.any? true
        end
      end
    end
  end
end
