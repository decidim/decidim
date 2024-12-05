# frozen_string_literal: true

module Decidim
  # Class to manage a collection of workflows
  class WorkflowRegistry
    attr_reader :workflow_collection

    def initialize(workflow_manifest_class)
      @workflow_manifest_class = workflow_manifest_class
      @workflow_collection = Set.new
    end

    #
    # Registers a new workflow using the workflow manifest API
    #
    def register_workflow(name)
      manifest = @workflow_manifest_class.new(name: name.to_s)
      yield(manifest)
      add_workflow(manifest)
    end

    #
    # Unregisters a workflow using the workflow manifest API
    #
    def unregister_workflow(manifest)
      manifest = find_workflow_manifest(manifest) if manifest.is_a?(String)
      workflow_collection.delete(manifest)
    end

    #
    # Restores registered workflows to the array being passed in
    #
    # Useful for testing.
    #
    def reset_workflows(*manifests)
      clear_workflows

      manifests.each do |manifest|
        add_workflow(manifest)
      end
    end

    #
    # Finds a workflow by name
    #
    def find_workflow_manifest(name)
      workflow_collection.find { |workflow| workflow.name == name.to_s }
    end

    private

    def add_workflow(manifest)
      manifest.validate!
      workflow_collection.add(manifest)
    end

    def clear_workflows
      workflow_collection.clear
    end
  end
end
