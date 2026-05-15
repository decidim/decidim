# frozen_string_literal: true

module Decidim
  module Verifications
    autoload :Adapter, "decidim/verifications/adapter"
    autoload :WorkflowManifest, "decidim/verifications/workflow_manifest"

    include Decidim::HasWorkflows

    def self.workflow_manifest_class = WorkflowManifest
  end
end
