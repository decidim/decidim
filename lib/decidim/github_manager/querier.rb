# frozen_string_literal: true

require "faraday"
require "json"

module Decidim
  module GithubManager
    # Allows to make GET requests to GitHub Rest API about Issues and Pull Requests
    # @see https://docs.github.com/en/rest
    class Querier
      def initialize(token:, issue_id:)
        @token = token
        @issue_id = issue_id
      end

      # Makes the GET request and parses the response of an Issue or Pull Request in GitHub
      #
      # @return [Hash]
      def call
        data = issue_metadata
        return unless data["number"]

        parse(issue_metadata)
      end

      private

      attr_reader :token, :issue_id

      # Makes a GET request for the metadata of an Issue or Pull Request in GitHub
      #
      # @see https://docs.github.com/en/rest/issues/issues#get-an-issue GitHub API documentation
      # @return [Hash]
      def issue_metadata
        uri = "https://api.github.com/repos/decidim/decidim/issues/#{issue_id}"
        response = Faraday.get(uri, nil, { Authorization: "token #{token}" })
        JSON.parse(response.body)
      end

      # Parses the response of an Issue or Pull Request in GitHub
      #
      # @return [Hash]
      def parse(metadata)
        labels = metadata["labels"].map { |l| l["name"] }.sort

        {
          id: metadata["number"],
          title: metadata["title"],
          labels:,
          type: labels.select { |l| l.match(/^type: /) || l == "target: developer-experience" },
          modules: labels.select { |l| l.match(/^module: /) }
        }
      end
    end
  end
end
