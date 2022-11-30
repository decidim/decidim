# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module ResourceVersionsConcern
    extend ActiveSupport::Concern

    included do
      helper Decidim::TraceabilityHelper
      helper_method :current_version, :versioned_resource

      def show
        raise ActionController::RoutingError, "Not found" unless current_version
      end

      private

      # Overwrite this method in your controller to define how to find the
      # versioned resource.
      def versioned_resource
        raise StandardError, "Not implemented"
      end

      def current_version
        return nil unless params[:id].to_i.positive?

        @current_version ||= versioned_resource.versions[params[:id].to_i - 1]
      end
    end
  end
end
