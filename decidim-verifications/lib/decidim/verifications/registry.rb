# frozen_string_literal: true

require "decidim/verifications/workflow_manifest"

module Decidim
  module Verifications
    #
    # Takes care of holding and accessing verification methods.
    #
    class Registry
      def register_workflow(name)
        manifest = WorkflowManifest.new(name: name.to_s)
        yield(manifest)
        add_workflow(manifest)
      end

      def add_workflow(manifest)
        manifest.validate!
        workflow_collection.add(manifest)
      end

      def clear_workflows
        workflow_collection.clear
      end

      def reset_workflows(*manifests)
        clear_workflows

        manifests.each do |manifest|
          add_workflow(manifest)
        end
      end

      def workflow_collection
        @workflow_collection ||= Set.new
      end
    end
  end
end
