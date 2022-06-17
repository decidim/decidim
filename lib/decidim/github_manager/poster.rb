# frozen_string_literal: true

require "faraday"
require "json"

module Decidim
  module GithubManager
    # Allows to make POSTS requests to GitHub about Pull Requests
    class Poster
      def initialize(token:, params:)
        @token = token
        @params = params
      end

      def call
        response = create_pull_request!
        pull_request_id = JSON.parse(response.body)["number"]
        unless pull_request_id
          puts "Pull request could not be created!"
          puts "Please make sure you have enabled the 'public_repo' scope for the access token"
          return
        end
        puts "Pull request created at https://github.com/decidim/decidim/pull/#{pull_request_id}"

        # GitHub doesn't support adding labels while creating the PR,
        # so we need to do it afterwards
        add_labels_to_issue!(pull_request_id)
      end

      private

      attr_reader :token, :params

      def post!(path, some_params)
        uri = "https://api.github.com/repos/decidim/decidim/#{path}"
        Faraday.post(uri, some_params.to_json, { Authorization: "token #{token}" })
      end

      def create_pull_request!
        puts "Creating the PR in GitHub"
        post!("pulls", params.except(:labels))
      end

      def add_labels_to_issue!(issue_id)
        puts "Adding the labels to the PR"
        post!("issues/#{issue_id}/labels", params.slice(:labels))
      end
    end
  end
end
