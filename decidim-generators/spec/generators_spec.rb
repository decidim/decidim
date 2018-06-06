# frozen_string_literal: true

require "simplecov" if ENV["SIMPLECOV"]
require "spec_helper"
require "decidim/gem_manager"

module Decidim
  describe Generators do
    let(:env) do |example|
      if ENV["SIMPLECOV"]
        {
          "RUBYOPT" => "-rsimplecov #{ENV["RUBYOPT"]}",
          "RUBYLIB" => "#{repo_root}/decidim-generators/lib",
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

    shared_examples_for "a sane generator" do
      it "successfully generates application" do
        expect(result[1]).to be_success, result[0]
      end
    end

    # rubocop:disable RSpec/BeforeAfterAll
    before(:all) do
      Decidim::GemManager.run_all(
        "gem build %name && mv %name-%version.gem ..",
        include_root: false,
        out: File::NULL
      )

      Decidim::GemManager.new(repo_root).run(
        "gem build %name && gem install *.gem",
        out: File::NULL
      )
    end

    after(:all) do
      Decidim::GemManager.run_all(
        "gem uninstall %name -v %version --executables --force",
        out: File::NULL
      )

      Decidim::GemManager.new(repo_root).run(
        "rm decidim-*.gem",
        out: File::NULL
      )
    end
    # rubocop:enable RSpec/BeforeAfterAll

    context "with an application" do
      let(:test_app) { "spec/generator_test_app" }

      after { FileUtils.rm_rf(test_app) }

      context "without flags" do
        let(:command) { "decidim #{test_app}" }

        it_behaves_like "a sane generator"
      end

      context "with --edge flag" do
        let(:command) { "decidim --edge #{test_app}" }

        it_behaves_like "a sane generator"
      end

      context "with --branch flag" do
        let(:command) { "decidim --branch master #{test_app}" }

        it_behaves_like "a sane generator"
      end

      context "with --path flag" do
        let(:command) { "decidim --path #{repo_root} #{test_app}" }

        it_behaves_like "a sane generator"
      end

      context "with a development application" do
        let(:command) { "decidim --path #{repo_root} #{test_app} --recreate_db --seed_db" }

        it_behaves_like "a sane generator"
      end
    end

    context "with a component" do
      let(:test_component) { "dummy_component" }
      let(:command) { "decidim --component #{test_component}" }

      after { FileUtils.rm_rf("decidim-module-#{test_component}") }

      it_behaves_like "a sane generator"
    end

    private

    def repo_root
      File.expand_path(File.join("..", ".."), __dir__)
    end
  end
end
