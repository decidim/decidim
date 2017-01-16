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

  feature.settings(:global) do |settings|
    settings.attribute :dummy_global_attribute_1, type: :boolean
    settings.attribute :dummy_global_attribute_2, type: :boolean
  end

  feature.settings(:step) do |settings|
    settings.attribute :dummy_step_attribute_1, type: :boolean
    settings.attribute :dummy_step_attribute_2, type: :boolean
  end
end

RSpec.configure do |config|
  config.before(:each) do
    Decidim.find_feature_manifest(:dummy).reset_hooks!
  end
end
