# frozen_string_literal: true

require "faraday"
require "json"

module Decidim
  module GithubManager
    # Allows to make POST requests to GitHub Rest API about Pull Requests
    # @see https://docs.github.com/en/rest
    class Poster
      # @param token [String] token for GitHub authentication
      # @param params [Hash] Parameters accepted by the GitHub API
      def initialize(token:, params:)
        @token = token
        @params = params
      end

      # Create the pull request or give error messages
      #
      # @return [Faraday::Response] An instance that represents an HTTP response from making an HTTP request
      def call
        response = create_pull_request!
        pull_request_id = JSON.parse(response.body)["number"]
        unless pull_request_id
          puts "Pull request could not be created!"
          puts "Please make sure you have enabled the 'public_repo' scope for the access token"
          return
        end
        puts "Pull request created at https://github.com/decidim/decidim/pull/#{pull_request_id}"

        add_labels_to_issue!(pull_request_id)
      end

      private

      attr_reader :token, :params

      # Make the POST request to GitHub API of the decidim repository
      #
      # @param path [String] The path to do the request to the GitHub API
      # @param some_params [Hash] The parameters of the request
      # @return [Faraday::Response] An instance that represents an HTTP response from making an HTTP request
      def post!(path, some_params)
        uri = "https://api.github.com/repos/decidim/decidim/#{path}"
        Faraday.post(uri, some_params.to_json, { Authorization: "token #{token}" })
      end

      # Create a pull request using the GitHub API
      #
      # @see https://docs.github.com/en/rest/pulls/pulls#create-a-pull-request GitHub API documentation
      # @return [Faraday::Response] An instance that represents an HTTP response from making an HTTP request
      def create_pull_request!
        puts "Creating the PR in GitHub"
        post!("pulls", params.except(:labels))
      end

      # Add labels to an issue or a pull request
      # GitHub doesn't support adding labels while creating the PR, so we need to do it afterwards
      #
      # @see https://docs.github.com/en/rest/issues/labels#add-labels-to-an-issue GitHub API documentation
      # @param issue_id [String] String of the issue to add the labels to
      # @return [Faraday::Response] An instance that represents an HTTP response from making an HTTP request
      def add_labels_to_issue!(issue_id)
        puts "Adding the labels to the PR"
        post!("issues/#{issue_id}/labels", params.slice(:labels))
      end
    end
  end
end
