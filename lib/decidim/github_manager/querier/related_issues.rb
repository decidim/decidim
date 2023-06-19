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
          parse(json_response)
        end

        private

        attr_reader :issue_id

        def uri
          "https://api.github.com/repos/decidim/decidim/issues/#{issue_id}/timeline"
        end

        # Parses the response of an Issue or Pull Request in GitHub
        #
        # @return [Hash]
        def parse(metadata)
          references = metadata.select do |item|
            item["event"] == "cross-referenced"
          end
          references.map do |item|
            {
              issue_id: item["source"]["issue"]["number"],
              title: item["source"]["issue"]["title"],
              state: item["source"]["issue"]["state"]
            }
          end
        end
      end
    end
  end
end
