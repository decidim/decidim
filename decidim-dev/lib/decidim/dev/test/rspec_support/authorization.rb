# frozen_string_literal: true

require "decidim/verifications/workflows"

module Decidim
  module Verifications
    module DummyVerification
      # Dummy engine to be able to test verifications.
      class Engine < ::Rails::Engine
        isolate_namespace Decidim::Verifications::DummyVerification

        paths["lib/tasks"] = nil

        routes do
          root to: proc { [200, {}, ["DUMMY VERIFICATION ENGINE"]] }
          get :edit_authorization, to: proc { [200, {}, ["CONTINUE YOUR VERIFICATION"]] }
        end
      end
    end
  end
end

Decidim::Verifications.register_workflow(:dummy_authorization_workflow) do |workflow|
  workflow.engine = Decidim::Verifications::DummyVerification::Engine
  workflow.expires_in = 1.hour
end

RSpec.configure do |config|
  config.around(:example, :with_authorization_workflows) do |example|
    begin
      previous_workflows = Decidim::Verifications.workflows.dup

      new_workflows = example.metadata[:with_authorization_workflows].map do |name|
        Decidim::Verifications.find_workflow_manifest(name)
      end

      Decidim::Verifications.reset_workflows(*new_workflows)
      Rails.application.reload_routes!

      example.run
    ensure
      Decidim::Verifications.reset_workflows(*previous_workflows)
      Rails.application.reload_routes!
    end
  end
end
