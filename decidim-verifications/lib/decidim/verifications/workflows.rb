# frozen_string_literal: true

module Decidim
  module Verifications
    autoload :Adapter, "decidim/verifications/adapter"
    autoload :Registry, "decidim/verifications/registry"

    #
    # Provides direct access to the verification registry
    #
    class << self
      delegate :clear_workflows, to: :registry

      #
      # Restores registered verification workflows to the array being passed in
      #
      # Useful for testing.
      #
      def reset_workflows(*manifests)
        registry.reset_workflows(*manifests)
      end

      #
      # Registers a new verification workflow using the workflow manifest API
      #
      def register_workflow(name, &)
        registry.register_workflow(name, &)
      end

      #
      # Unregisters a verification workflow using the workflow manifest API
      #
      def unregister_workflow(name)
        manifest = find_workflow_manifest(name)

        registry.unregister_workflow(manifest)
      end

      #
      # Finds a verification workflow by name
      #
      def find_workflow_manifest(name)
        workflows.find { |workflow| workflow.name == name.to_s }
      end

      #
      # Collection of registered verification workflows
      #
      def workflows
        registry.workflow_collection
      end

      #
      # Collection of registered verification workflows having an admin engine
      #
      def admin_workflows
        workflows.select(&:admin_engine)
      end

      private

      def registry
        @registry ||= Registry.new
      end
    end
  end
end
