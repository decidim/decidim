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

          message_str =
            if messages.is_a?(ActiveModel::Errors)
              messages.full_messages.join(", ")
            elsif messages.is_a?(Array)
              messages.map { |a| a[:message] }.join(", ")
            else
              messages.to_s
            end
          super(message_str)
        end

        def to_h
          hash = {}
          if @messages.is_a?(ActiveModel::Errors)
            hash["message"] = @messages.map do |error|
              # This is the GraphQL argument which corresponds to the validation error:
              local_path = ["attributes", error.attribute.to_s.camelize(:lower)]
              {
                path: local_path,
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
          return @messages.map { |a| [a[:path].last, a[:message]].join(": ") }.join(", ") if @messages.is_a?(Array)

          @messages.to_s
        end
      end
    end
  end
end
