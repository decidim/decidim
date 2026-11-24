# frozen_string_literal: true

module Decidim
  # Shared behaviour for controllers that need an organization present in order
  # to work. The organization is injected via the CurrentOrganization
  # middleware.
  module NeedsOrganization
    def self.enhance_controller(instance_or_module)
      instance_or_module.class_eval do
        before_action :verify_organization
        helper_method :current_organization
      end
    end

    def self.extended(base)
      base.extend InstanceMethods

      enhance_controller(base)
    end

    def self.included(base)
      base.include InstanceMethods

      enhance_controller(base)
    end

    module InstanceMethods
      # The current organization for the request.
      #
      # Returns an Organization.
      def current_organization
        @current_organization ||= request.env["decidim.current_organization"]
      end

      private

      def verify_organization
        redirect_to decidim_system.root_path unless current_organization
      end

      # Checks whether the given resource belongs to the current organization.
      def in_organization?(resource)
        return false if resource.blank?

        resource.organization == current_organization
      end

      # Raises ActiveRecord::RecordNotFound when the given resource belongs to
      # another organization. Blank resources are handled by the callers.
      def ensure_in_organization!(resource)
        return if resource.blank? || in_organization?(resource)

        raise ActiveRecord::RecordNotFound
      end
    end
  end
end
