# frozen_string_literal: true

module Decidim
  module Api
    # Base controller for `decidim-api`. All other controllers inherit from this.
    class GraphiqlController < ::GraphiQL:Rails::EditorsController
      include NeedsOrganization
      include ForceAuthentication

      def self.controller_path
        "graphiql/rails/editors"
      end
    end
  end
end
