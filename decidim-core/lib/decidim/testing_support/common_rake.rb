require_relative '../../../../decidim-core/lib/generators/decidim/dummy_generator'

desc "Generates a dummy app for testing"
namespace :common do
  task :test_app do |_t, _args|
    Decidim::Generators::DummyGenerator.start [
      "--lib_name=#{ENV['LIB_NAME']}",
      "--migrate=true",
      "--quiet"
    ]
  end
end
