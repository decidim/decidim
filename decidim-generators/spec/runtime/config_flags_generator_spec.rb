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
        let(:default_branch) { Decidim::Generators.edge_git_branch }
        let(:command) { "decidim --branch #{default_branch} #{test_app}" }

        it_behaves_like "a new production application"
      end

      context "with --path flag" do
        let(:command) { "decidim --path #{repo_root} #{test_app}" }

        it_behaves_like "a new production application"
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

      context "with --queue providers" do
        let(:command) { "decidim #{test_app} --storage s3 --queue sidekiq" }

        it_behaves_like "an application with storage and queue gems"
      end
    end

    context "with a component" do
      let(:test_component) { "dummy_component" }
      let(:command) { "decidim --component #{test_component}" }
      let(:semver_friendly_version) { Decidim::GemManager.semver_friendly_version(Decidim.version) }
      let(:npm_package_version) { "^#{semver_friendly_version}" }

      after { FileUtils.rm_rf("decidim-module-#{test_component}") }

      it "succeeds" do
        expect(result[1]).to be_success, result[0]

        expect(JSON.parse(File.read("decidim-module-#{test_component}/package.json"))).to eq(
          "name" => "decidim-#{test_component}",
          "version" => "0.0.1",
          "description" => "",
          "private" => true,
          "license" => "AGPL-3.0",
          "scripts" => {
            "lint" => "eslint -c .eslintrc.json --no-error-on-unmatched-pattern --ignore-pattern app/packs/vendor --ext .js app/packs",
            "stylelint" => "stylelint app/packs/**/*.scss"
          },
          "dependencies" => {
            "@decidim/browserslist-config" => npm_package_version,
            "@decidim/webpacker" => npm_package_version
          },
          "devDependencies" => {
            "@decidim/dev" => npm_package_version,
            "@decidim/eslint-config" => npm_package_version,
            "@decidim/stylelint-config" => npm_package_version
          },
          "browserslist" => ["extends @decidim/browserslist-config"]
        )
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
