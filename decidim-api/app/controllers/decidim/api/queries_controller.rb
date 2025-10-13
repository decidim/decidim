# frozen_string_literal: true

module Decidim
  module Api
    # This controller takes queries from an HTTP endpoint and sends them out to
    # the Schema to be executed, later returning the response as JSON.
    class QueriesController < Api::ApplicationController
      before_action :parse_multipart, only: :create

      def create
        variables = prepare_variables(params[:variables])
        query = params[:query]
        operation_name = params[:operationName]
        result = Schema.execute(query, variables:, context:, operation_name:)
        render json: result
      rescue StandardError => e
        logger.error e.message
        logger.error e.backtrace.join("\n")

        message = if Rails.env.development?
                    { message: e.message, backtrace: e.backtrace }
                  else
                    { message: "Internal Server error" }
                  end

        render json: { errors: [message], data: {} }, status: :internal_server_error
      end

      private

      def prepare_variables(variables_param)
        case variables_param
        when String
          if variables_param.present?
            JSON.parse(variables_param) || {}
          else
            {}
          end
        when Hash
          variables_param
        when ActionController::Parameters
          variables_param.to_unsafe_hash # GraphQL-Ruby will validate name and type of incoming variables.
        when nil
          {}
        else
          raise ArgumentError, "Unexpected parameter: #{variables_param}"
        end
      end

      def parse_multipart
        return unless params[:operations] && params[:map]

        operations = JSON.parse(params[:operations])
        map = JSON.parse(params[:map])

        # Single file only
        file_key, paths = map.first
        file = params[file_key]
        raise "Uploaded file missing in params[#{file_key}]" unless file

        paths.each do |path|
          keys = path.split(".") 
          last_key = keys.pop

          parent = operations
          keys.each { |k| parent = parent[k.to_s] }

          parent[last_key] = file
        end

        params[:query] = operations["query"]
        params[:variables] = operations["variables"]
        params[:operationName] = operations["operationName"]
      end
    end
  end
end
