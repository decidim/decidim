# frozen_string_literal: true

require "decidim/gem_manager"

module Decidim
  describe Generators do
    let(:result) do
      Bundler.with_original_env { GemManager.run(command, out: File::NULL) }
    end

    let(:test_app) { "spec/generator_test_app" }

    after { FileUtils.rm_rf(test_app) }

    shared_examples_for "a sane generator" do
      it "successfully generates application" do
        expect(result[1]).to be_success, result[0]
      end
    end

    # rubocop:disable RSpec/BeforeAfterAll
    before(:all) do
      Bundler.with_original_env do
        GemManager.run("rake install_all", out: File::NULL)
      end
    end

    after(:all) do
      Bundler.with_original_env do
        GemManager.run("rake uninstall_all", out: File::NULL)
      end
    end
    # rubocop:enable RSpec/BeforeAfterAll

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
      let(:command) { "decidim --path #{File.expand_path(File.join("..", ".."), __dir__)} #{test_app}" }

      it_behaves_like "a sane generator"
    end

    context "with development application" do
      let(:command) do
        "decidim --path #{File.expand_path(File.join("..", ".."), __dir__)} #{test_app} --recreate_db --seed_db"
      end

      it_behaves_like "a sane generator"
    end
  end
end
