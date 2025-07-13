# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # A concern to include logic to manage workflows inside a module. The method
  # workflow_manifest_class must be implemented returning the class which
  # implements the workflow manifest API
  module HasWorkflows
    extend ActiveSupport::Concern

    autoload :WorkflowRegistry, "decidim/workflow_registry"

    class_methods do
      delegate :workflow_collection, :register_workflow, :unregister_workflow, :reset_workflows, :find_workflow_manifest, to: :registry

      #
      # Collection of registered workflows
      #
      def workflows
        workflow_collection
      end

      #
      # Collection of registered workflows having an admin engine
      #
      def admin_workflows
        workflows.select(&:admin_engine)
      end

      def workflow_manifest_class
        raise NotImplementedError, "You must define a workflow manifest class"
      end

      private

      def registry
        @registry ||= WorkflowRegistry.new(workflow_manifest_class)
      end
    end
  end
end
