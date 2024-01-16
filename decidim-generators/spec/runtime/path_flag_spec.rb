# frozen_string_literal: true

require "spec_helper"
require "decidim/generators/test/generator_examples"

module Decidim
  describe Generators do
    include_context "when generating a new application"

    context "with an application" do
      let(:test_app) { "spec/generator_test_app" }

      after { FileUtils.rm_rf(test_app) }

      context "with --path flag" do
        let(:command) { "decidim --path #{repo_root} #{test_app}" }

        it_behaves_like "a new production application"
      end

      context "with a development application" do
        let(:command) { "decidim --path #{repo_root} #{test_app} --recreate_db --seed_db --demo" }

        it_behaves_like "a new development application"
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
  end
end
