# frozen_string_literal: true
Decidim.register_feature(:dummy) do |feature|
  feature.component(:dummy)
end

RSpec.configure do |config|
  config.before(:each) do
    Decidim.find_feature_manifest(:dummy).component_manifests.each(&:reset_hooks!)
  end
end
