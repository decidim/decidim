# frozen_string_literal: true

require "active_support/all"
require "active_support/testing/stream"
require "fileutils"
require "tempfile"
require "redis"
require "decidim/generators"
require "decidim/generators/app_generator"

module Decidim
  module Generators
    describe AppGenerator do
      include ActiveSupport::Testing::Stream

      let(:generator) do
        described_class.new(
          [destination_root],
          generator_options.merge(skip_bundle: true),
          generator_config.reverse_merge(destination_root:)
        )
      end
      let(:generator_options) { {} }
      let(:generator_config) { {} }
      let(:destination_root) { File.expand_path("spec/generator_test_app") }

      let(:development_config_content) { File.read("config/environments/development.rb") }
      let(:production_config_content) { File.read("config/environments/production.rb") }
      let(:routes_content) { File.read("config/routes.rb") }
      let(:gemfile_content) { File.read("Gemfile") }

      around do |example|
        # Generate the necessary base files for the tests.
        original_cwd = Dir.pwd

        begin
          capture(:stdout) do
            generator.create_root
            generator.create_root_files
            generator.create_config_files
          end

          example.run
        ensure
          Dir.chdir(original_cwd)
          FileUtils.rm_rf(destination_root)
        end
      end

      shared_examples_for "app with sidekiq" do
        it "adds the sidekiq configuration" do
          subject
          expect(File.exist?("config/sidekiq.yml")).to be(true)
          expect(gemfile_content).to match(/^gem "sidekiq"/)
          expect(development_config_content).to include("config.active_job.queue_adapter = :sidekiq")
          expect(production_config_content).to include("config.active_job.queue_adapter = ENV['QUEUE_ADAPTER'] if ENV['QUEUE_ADAPTER'].present?")
          expect(routes_content).to match(%r{^require "sidekiq/web"$})
          expect(routes_content).to include(%(mount Sidekiq::Web => "/sidekiq"))
        end
      end

      shared_examples_for "app without sidekiq" do
        it "does not add the sidekiq configuration" do
          subject
          expect(File.exist?("config/sidekiq.yml")).to be(false)
          expect(gemfile_content).not_to match(/^gem "sidekiq"/)
          expect(development_config_content).not_to include("config.active_job.queue_adapter = :sidekiq")
          expect(production_config_content).not_to include("config.active_job.queue_adapter = ENV['QUEUE_ADAPTER'] if ENV['QUEUE_ADAPTER'].present?")
          expect(routes_content).not_to match(%r{^require "sidekiq/web"$})
          expect(routes_content).not_to include(%(mount Sidekiq::Web => "/sidekiq"))
        end
      end

      describe "#add_queue_adapter" do
        subject do
          capture(:stdout) { generator.add_queue_adapter }
        end

        context "with empty flag" do
          let(:generator_options) { { queue: "" } }

          it_behaves_like "app without sidekiq"
        end

        context "with sidekiq flag" do
          let(:generator_options) { { queue: "sidekiq" } }
          let(:redis_version) { nil }

          before do
            dummy_redis = double
            allow(dummy_redis).to receive(:call).with("INFO").and_return("redis_version:#{redis_version}")
            allow(::Redis).to receive(:new).and_return(dummy_redis)
          end

          context "with version < 6.2.0" do
            let(:redis_version) { "6.1.0" }

            it "warns about old version and does not add the queue adapter" do
              expect(generator).to receive(:warn)
              subject
            end

            it_behaves_like "app without sidekiq" do
              # Silence the message.
              before { allow(generator).to receive(:warn) }
            end
          end

          context "with version < 7.0.0" do
            let(:redis_version) { "6.9.0" }

            it "adds the correct queue adapter version" do
              subject
              expect(gemfile_content).to match(/^gem "sidekiq", "~> 7.3"$/)
            end

            it_behaves_like "app with sidekiq"
          end

          context "with version >= 7.0.0" do
            let(:redis_version) { "7.0.0" }

            it "adds the correct queue adapter version" do
              subject
              expect(gemfile_content).to match(/^gem "sidekiq"$/)
            end

            it_behaves_like "app with sidekiq"
          end
        end

        context "with unknown flag" do
          let(:generator_options) { { queue: "unknown" } }

          it "aborts the process" do
            expect(generator).to receive(:abort)
            subject
          end

          it_behaves_like "app without sidekiq" do
            # Silence the message.
            before { allow(generator).to receive(:abort) }
          end
        end
      end
    end
  end
end
