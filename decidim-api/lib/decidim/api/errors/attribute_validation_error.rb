# frozen_string_literal: true

module Decidim
  module Api
    module Errors
      class AttributeValidationError < GraphQL::ExecutionError
        def initialize(messages, ast_node: nil, options: nil, extensions: nil)
          @ast_node = ast_node
          @options = options
          @extensions = extensions

          @messages = messages

          super(messages.full_messages.join(", ")) if messages.is_a?(ActiveModel::Errors)
        end

        def to_h
          hash = {}
          if @messages.is_a?(ActiveModel::Errors)
            hash["message"] = @messages.map do |error|
              # This is the GraphQL argument which corresponds to the validation error:
              path = ["attributes", error.attribute.to_s.camelize(:lower)]
              {
                path: path,
                message: error.message
              }
            end
          end

          hash["message"] = @messages if @messages.is_a?(Array)

          if ast_node
            hash["locations"] = [
              {
                "line" => ast_node.line,
                "column" => ast_node.col
              }
            ]
          end

          hash["path"] = path if path

          hash.merge!(options) if options

          if extensions
            hash["extensions"] = extensions.transform_keys do |(key, value), ext|
              ext[key.to_s] = value
            end
          end

          hash.merge!({ "extensions" => { "code" => "ATTRIBUTE_VALIDATION_ERROR" } })

          hash
        end

        def message
          return @messages.full_messages.join(", ") if @messages.is_a?(ActiveModel::Errors)

          @messages.map { |a| a[:message] }.join(", ")
        end
      end
    end
  end
end
