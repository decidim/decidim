# frozen_string_literal: true

module Decidim
  module ApiResponseHelper
    # When passing the JSON types as a variables, it results to a string type.
    def json_value(value)
      return JSON.parse(value) if value.is_a?(String)

      value
    end
  end
end
