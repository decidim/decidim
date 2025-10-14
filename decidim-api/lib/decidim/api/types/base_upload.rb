# frozen_string_literal: true

module Decidim
  module Api
    module Types
      class BaseUpload < BaseScalar
        description "An uploaded file"
        graphql_name "BaseUpload"

        def self.coerce_input(value, _ctx)
          if value.nil? || value.is_a?(::Rack::Multipart::UploadedFile)
            return value
          elsif value.is_a?(ActionDispatch::Http::UploadedFile)
            # Wrap Rails uploaded file in a Rack::Multipart::UploadedFile-compatible object
            return ::Rack::Multipart::UploadedFile.new(
              value.tempfile.path,
              value.content_type,
              filename: value.original_filename
            )
          end

          raise GraphQL::CoercionError, "#{value.inspect} is not a valid upload"
        end
      end
    end
  end
end
