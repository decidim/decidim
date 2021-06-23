# frozen_string_literal: true

module Decidim
  module Api
    # Controller to serve the GraphiQL client. Used so that we can hook the
    # `ForceAuthentication` module.
    class GraphiQLController < Api::ApplicationController
      include NeedsOrganization
      include ForceAuthentication

      def show; end

      helper_method :graphql_endpoint_path
      def graphql_endpoint_path
        params[:graphql_path]
      end
    end
  end
end
