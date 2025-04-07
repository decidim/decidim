# frozen_string_literal: true

module Decidim
  module Initiatives
    module Signatures
      autoload :SignatureWorkflowManifest, "decidim/initiatives/signature_workflow_manifest"
      include Decidim::HasWorkflows

      def self.workflow_manifest_class = SignatureWorkflowManifest
    end
  end
end
