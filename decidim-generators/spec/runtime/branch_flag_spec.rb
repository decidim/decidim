# frozen_string_literal: true

if ENV["SIMPLECOV"]
  require "simplecov"

  SimpleCov.add_filter "/lib/decidim/generators/app_templates/"
  SimpleCov.add_filter "/lib/decidim/generators/component_templates/"
end

require "spec_helper"
require "json"
require "fileutils"
require "decidim/gem_manager"
require "decidim/generators/test/generator_examples"

module Decidim
  describe Generators do
    let(:env) do |example|
      #
      # When tracking coverage, make sure the ruby environment points to the
      # local version, so we get the benefits of running `decidim` directly
      # without `bundler` (more realistic test), but also get code coverage
      # properly measured (we track coverage on the local version and not on the
      # installed version).
      #
      if ENV["SIMPLECOV"]
        {
          "RUBYOPT" => "-rsimplecov #{ENV.fetch("RUBYOPT", nil)}",
          "RUBYLIB" => "#{repo_root}/decidim-generators/lib:#{ENV.fetch("RUBYLIB", nil)}",
          "PATH" => "#{repo_root}/decidim-generators/exe:#{ENV.fetch("PATH", nil)}",
          "COMMAND_NAME" => example.full_description.tr(" ", "_")
        }
      else
        {}
      end
    end

    let(:result) do
      Bundler.with_original_env { GemManager.capture(command, env:) }
    end

    # rubocop:disable RSpec/BeforeAfterAll
    before(:all) do
      Bundler.with_original_env { Decidim::GemManager.install_all(out: File::NULL) }
    end

    after(:all) do
      Bundler.with_original_env { Decidim::GemManager.uninstall_all(out: File::NULL) }
    end
    # rubocop:enable RSpec/BeforeAfterAll

    context "with an application" do
      let(:test_app) { "spec/generator_test_app" }

      after { FileUtils.rm_rf(test_app) }

      context "with --branch flag" do
        let(:default_branch) { Decidim::Generators.edge_git_branch }
        let(:command) { "decidim --branch #{default_branch} #{test_app}" }

        it_behaves_like "a new production application"
      end
    end

    private

    def repo_root
      File.expand_path(File.join("..", "..", ".."), __dir__)
    end

    def json_secrets_for(path, env)
      JSON.parse cmd_capture(path, "bin/rails runner 'puts Rails.application.secrets.to_json'", env:)
    end

    def initializer_config_for(path, env, mod = "Decidim")
      JSON.parse cmd_capture(path, "bin/rails runner 'puts #{mod}.config.to_json'", env:)
    end

    def rails_value(value, path, env)
      JSON.parse cmd_capture(path, "bin/rails runner 'puts #{value}.to_json'", env:)
    end

    def cmd_capture(path, cmd, env: {})
      Bundler.with_unbundled_env do
        Decidim::GemManager.new(path).capture(cmd, env:, with_stderr: false)[0]
      end
    end
  end
end
