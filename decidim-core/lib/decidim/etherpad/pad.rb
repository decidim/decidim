# frozen_string_literal: true

module Decidim
  module Etherpad
    # This class allows you to interact with pad stored in an Etherpad Lite server.
    class Pad
      def initialize(pad_id)
        @id = pad_id
        @api_key = Decidim.etherpad.fetch(:api_key)
        @api_version = Decidim.etherpad.fetch(:api_version, "1.2.1")
        @uri = URI.parse(Decidim.etherpad.fetch(:server))
      end

      attr_reader :id

      # Read only means that pad is not writable.
      def read_only_id
        @read_only_id ||= resolve(:getReadOnlyID, { padID: id })[:readOnlyID]
      end

      def text
        resolve(:getText, { padID: id })[:text]
      end

      private

      attr_reader :api_key, :uri, :api_version

      def resolve(method, params = {})
        path = "/api/#{api_version}/#{method}"
        result = get(path, params)
        response = JSON.parse(result.body.to_s, symbolize_names: true)

        case response[:code]
        when 0 then response[:data]
        when (1..4) then raise StandardError, response[:message]
        else raise Error, "An unknown error ocurred while handling the API response: #{response}"
        end
      end

      # Makes a GET request
      def get(path, params = {})
        params[:apikey] = api_key
        Faraday.get("#{uri}#{path}", params)
      end
    end
  end
end
