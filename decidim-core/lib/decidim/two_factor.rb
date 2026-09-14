# frozen_string_literal: true

module Decidim
  # Second-factor authentication: the registry of methods and module helpers.
  module TwoFactor
    include Decidim::HasWorkflows

    autoload :MethodManifest, "decidim/two_factor/method_manifest"
    autoload :CodeDigest, "decidim/two_factor/code_digest"

    def self.workflow_manifest_class = MethodManifest

    def self.available_methods(organization = nil)
      names = Array(Decidim.two_factor_methods).map(&:to_s)
      allowed = names & Array(organization&.available_two_factor_methods)
      names = allowed if allowed.any?

      names.filter_map { |name| find_workflow_manifest(name) }
    end
  end
end
