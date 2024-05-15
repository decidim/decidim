# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Design
    # Common logic of design controllers
    module HasTemplates
      extend ActiveSupport::Concern

      included do
        def show
          raise ActionController::RoutingError, "Not Found" unless lookup_context.exists?("decidim/design/#{controller_name}/#{params[:id]}")

          render "decidim/design/#{controller_name}/#{params[:id]}"
        end
      end
    end
  end
end
