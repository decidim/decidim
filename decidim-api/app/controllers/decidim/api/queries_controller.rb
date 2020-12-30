# frozen_string_literal: true

module Decidim
  module Api
    # This controller takes queries from an HTTP endpoint and sends them out to
    # the Schema to be executed, later returning the response as JSON.
    class QueriesController < Api::ApplicationController
      def create
        variables = prepare_variables(params[:variables])
        query = params[:query]
        operation_name = params[:operationName]
        result = Schema.execute(query, variables: variables, context: context, operation_name: operation_name)
        render json: result
      rescue StandardError => e
        raise e unless Rails.env.development?

        handle_error_in_development e
      end

      private

      def context
        {
          current_organization: current_organization,
          current_user: current_user
        }
      end

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

      def handle_error_in_development(e)
        logger.error e.message
        logger.error e.backtrace.join("\n")

        render json: { errors: [{ message: e.message, backtrace: e.backtrace }], data: {} }, status: :internal_server_error
      end
    end
  end
end
