# frozen_string_literal: true

require "json"
require "faraday"

module Decidim
  module GithubManager
    module Querier
      # Base class that allows making GET requests to GitHub Rest API about Issues and Pull Requests
      # This must be inherited from other class with the following methods:
      # - call
      # - uri
      # @see https://docs.github.com/en/rest
      class Base
        def initialize(token:)
          @token = token
        end

        def call
          raise "Not implemented"
        end

        def uri
          raise "Not implemented"
        end

        private

        attr_reader :token

        def headers
          nil
        end

        def response
          Faraday.get(uri, headers, { Authorization: "token #{token}" })
        end

        def json_response
          JSON.parse(response.body)
        end
      end
    end
  end
end
