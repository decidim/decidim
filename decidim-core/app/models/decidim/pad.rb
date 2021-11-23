# frozen_string_literal: true

module Decidim
  # This class allows you to interact with pad stored in an Etherpad Lite server.
  class Pad
    def initialize(pad_id)
      @id = pad_id
      @api_key = Decidim.etherpad.fetch(:api_key)
      @api_version = Decidim.etherpad.fetch(:api_version, "1.2.1")
      @uri = URI.parse(Decidim.etherpad.fetch(:server))
    end

    attr_reader :id

    # Returns the Pad's read-only id. Used when pad isn't writable.
    def read_only_id
      @read_only_id ||= resolve_read_only_id("/api/#{@api_version}/getReadOnlyID", { padID: id })
    end

    private

    attr_reader :api_key, :uri

    def resolve_read_only_id(path, params)
      result = get(path, params)
      response = JSON.parse(result.body.to_s, symbolize_names: true)

      case response[:code]
      when 0 then response[:data]
      when (1..4) then raise Error, response[:message]
      else raise Error, "An unknown error ocurrced while handling the API response: #{response}"
      end
    end

    # Makes a GET request
    def get(path, params = {})
      params[:apikey] = api_key
      Faraday.get("#{uri}#{path}", params)
    end
  end
end
