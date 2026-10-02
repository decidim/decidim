# frozen_string_literal: true

module Decidim
  module Api
    module Types
      class BaseUpload < BaseScalar
        description "An uploaded file"
        graphql_name "BaseUpload"

        def self.coerce_input(value, _ctx)
          return value if value.nil? || value.is_a?(::Rack::Multipart::UploadedFile) || value.is_a?(ActionDispatch::Http::UploadedFile)

          raise GraphQL::CoercionError, "#{value.inspect} is not a valid upload"
        end
      end
    end
  end
end
