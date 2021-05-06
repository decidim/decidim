# frozen_string_literal: true

if ENV["SIMPLECOV"]
  require "simplecov"

  SimpleCov.add_filter "/lib/decidim/generators/app_templates/"
  SimpleCov.add_filter "/lib/decidim/generators/component_templates/"
end

require "spec_helper"
require "decidim/gem_manager"

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

      shared_examples_for "a new production application" do
        it "includes optional plugins commented out in Gemfile" do
          expect(result[1]).to be_success, result[0]

          expect(File.read("#{test_app}/Gemfile"))
            .to match(/^# gem "decidim-initiatives"/)
            .and match(/^# gem "decidim-consultations"/)
            .and match(/^# gem "decidim-elections"/)
            .and match(/^# gem "decidim-conferences"/)
            .and match(/^# gem "decidim-templates"/)
        end
      end

      shared_examples_for "a new development application" do
        it "includes optional plugins uncommented in Gemfile" do
          expect(result[1]).to be_success, result[0]

          expect(File.read("#{test_app}/Gemfile"))
            .to match(/^gem "decidim-initiatives"/)
            .and match(/^gem "decidim-consultations"/)
            .and match(/^gem "decidim-elections"/)
            .and match(/^gem "decidim-conferences"/)
            .and match(/^gem "decidim-templates"/)

          # Checks that every table from a migration is included in the generated schema
          schema = File.read("#{test_app}/db/schema.rb")
          tables = []
          dropped = []
          Decidim::GemManager.plugins.each do |plugin|
            Dir.glob("#{plugin}db/migrate/*.rb").each do |migration|
              lines = File.readlines(migration)
              tables.concat(lines.filter { |line| line.match? "create_table" }.map { |line| line.match(/(:)([a-z_0-9]+)/)[2] })
              dropped.concat(lines.filter { |line| line.match? "drop_table" }.map { |line| line.match(/(:)([a-z_0-9]+)/)[2] })
              tables.concat(lines.filter { |line| line.match? "rename_table" }.map { |line| line.match(/(, :)([a-z_0-9]+)/)[2] })
              dropped.concat(lines.filter { |line| line.match? "rename_table" }.map { |line| line.match(/(:)([a-z_0-9]+)/)[2] })
            end
          end
          tables.each do |table|
            next if dropped.include? table

            expect(schema).to match(/create_table "#{table}"|create_table :#{table}/)
          end
        end
      end

      context "without flags" do
        let(:command) { "decidim #{test_app}" }

        it_behaves_like "a new production application"
      end

      context "with --branch flag" do
        let(:default_branch) { "release/0.24-stable" }
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
