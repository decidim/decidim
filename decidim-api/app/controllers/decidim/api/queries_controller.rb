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

      def context
        {
          current_organization:,
          current_user: api_user,
          scopes: api_scopes,
          can_introspect: Decidim::Api.enable_anonymous_introspection || api_user&.admin?
        }
      end

      # Determines the scopes for the user for API requests.
      #
      # @return [Doorkeeper::OAuth::Scopes]
      def api_scopes
        if doorkeeper_token
          doorkeeper_token.scopes
        elsif api_user.present?
          # In case a doorkeeper token is not available, we assume the user is
          # either:
          # - A regular authenticated user in Decidim using the API locally
          #   from within Decidim using the system with the cookie based
          #   authentication
          # - A Decidim::Api::ApiUser authenticated through the `/api/sign_in`
          #   endpoint for machine-to-machine integrations using the system with
          #   the assigned JSON Web Token (JWT).
          #
          # In both of these cases we assume all scopes as the user does not
          # request any specific scopes during the authentication process and
          # the user would be anyways able to perform any actions they are
          # normally allowed to perform within the regular user interface.
          ::Doorkeeper::OAuth::Scopes.from_array(::Doorkeeper.config.scopes.all)
        else
          # In case no user is present, we only allow the user to read the API.
          ::Doorkeeper::OAuth::Scopes.from_string("api:read")
        end
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

      def parse_multipart
        return unless params[:operations] && params[:map]

        operations = JSON.parse(params[:operations])
        map = JSON.parse(params[:map])

        raise "Invalid multipart map" if map.blank?

        map.each do |file_key, paths|
          file = params[file_key]
          raise "Uploaded file missing in params[#{file_key}]" unless file

          paths.each do |path|
            keys = path.split(".")
            last_key = keys.pop

            parent = operations
            keys.each do |k|
              if parent.is_a?(Array)
                index = k.to_i
                raise "Invalid array index in path: #{path}" unless index.to_s == k
                raise "Array index out of bounds in path: #{path}" unless index < parent.length

                parent = parent[index]
              elsif parent.is_a?(Hash)
                raise "Unsupported path segment :#{k} in path: #{path}" unless parent.key?(k)

                parent = parent[k]
              else
                raise "Unexpected parent type #{parent.class} in path: #{path}"
              end
            end

            if parent.is_a?(Array)
              index = last_key.to_i
              raise "Invalid array index in path: #{path}" unless index.to_s == last_key

              parent[index] = file
            elsif parent.is_a?(Hash)
              parent[last_key] = file
            else
              raise "Unexpected parent type #{parent.class} for assignment in path: #{path}"
            end
          end
        end

        params[:query] = operations["query"]
        params[:variables] = operations["variables"]
        params[:operationName] = operations["operationName"]
      end
    end
  end
end
