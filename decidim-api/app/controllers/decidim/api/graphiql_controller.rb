# frozen_string_literal: true

module Decidim
  module Api
    # Controller to serve the GraphiQL client. Used so that we can hook the
    # `ForceAuthentication` module.
    class GraphiQLController < ::GraphiQL::Rails::EditorsController
      include NeedsOrganization
      include ForceAuthentication

      def self.controller_path
        "graphiql/rails/editors"
      end
    end
  end
end
