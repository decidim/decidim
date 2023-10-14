# frozen_string_literal: true

require "spec_helper"
require "decidim/generators/test/generator_examples"

module Decidim
  describe Generators do
    include_context "when generating a new application"

    context "with an application" do
      let(:test_app) { "spec/generator_test_app" }

      after { FileUtils.rm_rf(test_app) }

      context "with a full featured application" do
        let(:command) { "decidim #{test_app} --recreate_db --demo" }

        it_behaves_like "a new development application"
        it_behaves_like "an application with extra configurable env vars"

        context "when running the db commands consecutively" do
          let(:command) { "decidim #{test_app} --demo --path #{repo_root}" }

          let(:subcommand) { "bundle exec rails db:drop db:create db:migrate db:seed" }
          let(:subresult) do
            Bundler.with_original_env { GemManager.new(test_app).capture(subcommand, env: {}) }
          end

          it "creates the app without errors" do
            expect(result[1]).to be_success, result[0]
            expect(subresult[1]).to be_success, subresult[0]
          end
        end
      end
    end
  end
end
