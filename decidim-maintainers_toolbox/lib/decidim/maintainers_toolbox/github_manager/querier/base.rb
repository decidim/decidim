# frozen_string_literal: true

require "json"
require "faraday"
require "uri"

module Decidim
  module GithubManager
    module Querier
      # Base class that allows making GET requests to GitHub Rest API about Issues and Pull Requests
      # This must be inherited from other class with the following methods:
      # - call
      # - uri
      # @see https://docs.github.com/en/rest
      class Base
        class InvalidMetadataError < StandardError; end

        def initialize(token:)
          @token = token
        end

        def call
          raise "Not implemented"
        end

        private

        attr_reader :token

        def headers
          nil
        end

        def authorization_header
          { Authorization: "token #{token}" }
        end

        def request(uri)
          response = Faraday.get(uri, headers, authorization_header)

          { body: response.body, headers: response.headers }
        end

        # Get's the JSON response from a URI
        # Supports pagination
        #
        # @param uri {String} - The URL that we want to get the JSON response from
        # @param old_json {Array} - The Array with the old_json or an empty Array if it's the first time that we're calling this method
        def json_response(uri, old_json = [])
          body, headers = request(uri).values_at(:body, :headers)
          json = JSON.parse(body)
          json.concat(old_json) if json.is_a?(Array)
          raise InvalidMetadataError if json.is_a?(Hash) && json["message"] == "Bad credentials"

          # If there are more pages, then we call ourselves redundantly to fetch the next page
          next_json = more_pages?(headers) ? json_response(next_page(headers), json) : []

          if json.is_a?(Array)
            # For some reason we have duplicated values, so we deduplicate them
            json.concat(next_json).uniq { |issue| issue.has_key?("number") ? issue["number"] : issue }
          else
            json
          end
        end

        def more_pages?(headers)
          return false if headers["link"].nil?

          headers["link"].include?('rel="next"')
        end

        def next_page(headers)
          URI.extract(headers["link"].split(",").select { |url| url.end_with?('rel="next"') }[0])[0]
        end
      end
    end
  end
end
