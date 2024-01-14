# frozen_string_literal: true

require_relative "base"

module Decidim
  module GithubManager
    module Querier
      # Makes a GET request for the related issues of an Issue or Pull Request in GitHub
      # Uses the Timeline events API endpoint
      #
      # @see https://docs.github.com/en/rest/issues/timeline?apiVersion=2022-11-28 GitHub API documentation
      class RelatedIssues < Decidim::GithubManager::Querier::Base
        def initialize(issue_id:, token:)
          @issue_id = issue_id
          @token = token
        end

        # Makes the GET request and parses the response of an Issue or Pull Request in GitHub
        #
        # @return [Hash]
        def call
          parse(json_response("https://api.github.com/repos/decidim/decidim/issues/#{@issue_id}/timeline"))
        end

        private

        def headers
          { per_page: 100 }
        end

        # Parses the response of an Issue or Pull Request in GitHub
        #
        # @return [Hash]
        def parse(metadata)
          references = metadata.select do |item|
            item["event"] == "cross-referenced" && item["source"]["issue"]["repository"]["full_name"] == "decidim/decidim"
          end
          references.map do |item|
            issue = item["source"]["issue"]

            {
              id: issue["number"],
              title: issue["title"].strip,
              state: issue.dig("pull_request", "merged_at").nil? ? issue["state"] : "merged"
            }
          end
        end
      end
    end
  end
end
