require_relative '../../../../decidim-core/lib/generators/decidim/dummy_generator'

desc "Generates a dummy app for testing"
namespace :common do
  task :test_app do |_t, args|
    args.with_defaults(user_class: "Spree::LegacyUser")

    p 'common:test_app:   ' + ENV['LIB_NAME']
    Decidim::Generators::DummyGenerator.start ["--lib_name=#{ENV['LIB_NAME']}", "--quiet"]
    p 'common:test_app:   YAYYYYYYYYYYY'
  end
end
