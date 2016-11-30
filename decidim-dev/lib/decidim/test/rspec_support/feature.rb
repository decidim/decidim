# frozen_string_literal: true

module Decidim
  # Dummy engine to be able to test components.
  class DummyEngine < Rails::Engine
    engine_name "dummy"

    routes do
      root to: proc { [200, {}, ["DUMMY ENGINE"]] }
    end
  end
end

Decidim.register_feature(:dummy) do |feature|
  feature.engine = Decidim::DummyEngine
end

RSpec.configure do |config|
  config.before(:each) do
    Decidim.find_feature_manifest(:dummy).reset_hooks!
  end
end
