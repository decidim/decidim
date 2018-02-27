# frozen_string_literal: true

module Decidim
  module Api
    # This controller takes queries from an HTTP endpoint and sends them out to
    # the Schema to be executed, later returning the response as JSON.
    class QueriesController < Api::ApplicationController
      skip_authorization_check
      around_action :store_current_user

      def create
        query_string = params[:query]
        query_variables = ensure_hash(params[:variables])
        result = Schema.execute(query_string, variables: query_variables, context: context)
        render json: result
      end

      private

      def context
        {
          current_organization: current_organization,
          current_user: current_user
        }
      end

      def ensure_hash(query_variables)
        if query_variables.blank?
          {}
        elsif query_variables.is_a?(String)
          JSON.parse(query_variables)
        else
          query_variables
        end
      end

      def store_current_user
        Thread.current[:current_user] = current_user
        yield
        ensure
        Thread.current[:current_user] = nil
      end
    end
  end
end
