# frozen_string_literal: true

module Decidim
  module Verifications
    autoload :Adapter, "decidim/verifications/adapter"
    autoload :Registry, "decidim/verifications/registry"

    class << self
      delegate :clear_workflows, to: :registry

      def reset_workflows(*manifests)
        registry.reset_workflows(*manifests)
      end

      def register_workflow(name, &block)
        registry.register_workflow(name, &block)
      end

      def find_workflow_manifest(name)
        workflows.find { |workflow| workflow.name == name.to_s }
      end

      def workflows
        registry.workflow_collection
      end

      def admin_workflows
        workflows.select(&:admin_engine)
      end

      def registry
        @registry ||= Registry.new
      end
    end
  end
end
