# frozen_string_literal: true

require_relative "base"

module Decidim::MaintainersToolbox
  module GithubManager
    module Querier
      # Makes a GET request for the list of Issues or Pull Requests in GitHub.
      #
      # @param token [String] token for GitHub authentication
      # @param title [String] the title that we want to search by
      # @param state [String] the state of the issue. By default is "open"
      #
      # @see https://docs.github.com/en/rest/issues/issues#list-repository-issues GitHub API documentation
      class ByTitle < Decidim::MaintainersToolbox::GithubManager::Querier::Base
        def initialize(title:, token:, state: "open")
          @title = title
          @token = token
          @state = state
        end

        # Makes the GET request and parses the response of an Issue or Pull Request in GitHub
        #
        # @return [Hash]
        def call
          data = json_response("https://api.github.com/repos/decidim/decidim/issues")

          parse(data)
        end

        private

        attr_reader :title, :state

        def headers
          {
            title: title,
            state: state,
            per_page: 100
          }
        end

        # Parses the response of an Issue or Pull Request in GitHub
        #
        # @return [Hash]
        def parse(metadata)
          metadata.map do |item|
            {
              id: item["number"],
              title: item["title"]
            }
          end
        end
      end
    end
  end
end
