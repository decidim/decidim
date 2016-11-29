# frozen_string_literal: true

module Decidim
  # Dummy engine to be able to test components.
  class DummyEngine < Rails::Engine
    engine_name "dummy"

    routes do
      root to: redirect("/")
    end
  end
end

Decidim.register_feature(:dummy) do |feature|
  feature.component(:dummy) do |component|
    component.engine = Decidim::DummyEngine
  end
end

RSpec.configure do |config|
  config.before(:each) do
    Decidim.find_feature_manifest(:dummy).component_manifests.each(&:reset_hooks!)
  end
end
