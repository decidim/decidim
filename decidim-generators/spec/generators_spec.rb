# frozen_string_literal: true

if ENV["SIMPLECOV"]
  require "simplecov"

  SimpleCov.add_filter "/lib/decidim/generators/app_templates/"
  SimpleCov.add_filter "/lib/decidim/generators/component_templates/"
end

require "spec_helper"
require "json"
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
          "RUBYOPT" => "-rsimplecov #{ENV["RUBYOPT"]}",
          "RUBYLIB" => "#{repo_root}/decidim-generators/lib:#{ENV["RUBYLIB"]}",
          "PATH" => "#{repo_root}/decidim-generators/exe:#{ENV["PATH"]}",
          "COMMAND_NAME" => example.full_description.tr(" ", "_")
        }
      else
        {}
      end
    end

    let(:result) do
      Bundler.with_original_env { GemManager.capture(command, env: env) }
    end

    # rubocop:disable RSpec/BeforeAfterAll
    before(:all) do
      Decidim::GemManager.install_all(out: File::NULL)
    end

    after(:all) do
      Decidim::GemManager.uninstall_all(out: File::NULL)
    end
    # rubocop:enable RSpec/BeforeAfterAll

    context "with an application" do
      let(:test_app) { "spec/generator_test_app" }

      after { FileUtils.rm_rf(test_app) }

      context "without flags" do
        let(:command) { "decidim #{test_app}" }

        it_behaves_like "a new production application"
        it_behaves_like "an application with configurable env vars"
      end

      context "with --edge flag" do
        let(:command) { "decidim --edge #{test_app}" }

        it_behaves_like "a new production application"
      end

      context "with --branch flag" do
        let(:default_branch) { "develop" }
        let(:command) { "decidim --branch #{default_branch} #{test_app}" }

        it_behaves_like "a new production application"
      end

      context "with --path flag" do
        let(:command) { "decidim --path #{repo_root} #{test_app}" }

        it_behaves_like "a new production application"
      end

      context "with a full featured application" do
        let(:command) { "decidim #{test_app} --recreate_db --demo" }

        it_behaves_like "a new development application"
      end

      context "with a development application" do
        let(:command) { "decidim --path #{repo_root} #{test_app} --recreate_db --seed_db --demo" }

        it_behaves_like "a new development application"
      end

      context "with wrong --storage providers" do
        let(:command) { "decidim #{test_app} --storage s3,gcs,assure" }

        it_behaves_like "an application with wrong cloud storage options"
      end

      context "with --storage providers" do
        let(:command) { "decidim #{test_app} --storage s3,gcs,azure" }

        it_behaves_like "an application with cloud storage gems"
      end
    end

    context "with a component" do
      let(:test_component) { "dummy_component" }
      let(:command) { "decidim --component #{test_component}" }

      after { FileUtils.rm_rf("decidim-module-#{test_component}") }

      it "suceeeds" do
        expect(result[1]).to be_success, result[0]
      end
    end

    private

    def repo_root
      File.expand_path(File.join("..", ".."), __dir__)
    end
  end
end
