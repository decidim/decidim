# frozen_string_literal: true

module Graphlient
  class Client
    def execute(query, variables = nil)
      ActiveSupport::Deprecation.warn "Remove me #{__FILE__}. I am here to offer support for Ruby 3.0, but now is not the case anymore" if Graphlient::VERSION == '0.5.0'
      query_params = {}
      query_params[:context] = @options if @options
      query_params[:variables] = variables if variables
      query = client.parse(query) if query.is_a?(String)
      rc = client.query(query, **query_params)
      raise Graphlient::Errors::GraphQLError, rc if rc.errors.any?
      # see https://github.com/github/graphql-client/pull/132
      # see https://github.com/exAspArk/graphql-errors/issues/2
      raise Graphlient::Errors::ExecutionError, rc if errors_in_result?(rc)
      rc
    rescue GraphQL::Client::Error => e
      raise Graphlient::Errors::ClientError, e.message
    end
  end
end
