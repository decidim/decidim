# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module ResourceVersionsConcern
    extend ActiveSupport::Concern

    included do
      helper Decidim::TraceabilityHelper
      helper_method :current_version, :versioned_resource

      def show
        enforce_permission_to(*versioned_resource_permission)

        raise ActionController::RoutingError, "Not found" unless current_version
      end

      private

      # The versions must honour the same `:read` permission as their resource,
      # so a resource that is hidden, private, deleted or unpublished (and
      # therefore cannot be read on its own) cannot be reached through its
      # versions either.
      def versioned_resource_permission
        resource = versioned_resource
        raise ActionController::RoutingError, "Not found" unless resource

        subject = resource.model_name.element.to_sym
        [:read, subject, { subject => resource }]
      end

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
