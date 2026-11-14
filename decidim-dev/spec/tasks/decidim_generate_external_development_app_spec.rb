# frozen_string_literal: true

require "spec_helper"

describe "rake decidim:generate_external_development_app", type: :task do
  around do |example|
    orig_dir = Dir.pwd
    Dir.chdir(__dir__)
    example.run
  ensure
    Dir.chdir(orig_dir)
  end

  context "when executing task" do
    before do
      # This is to ensure this spec passes even if the user has set the
      # QUEUE_ADAPTER env var locally.
      allow(ENV).to receive(:fetch).with("QUEUE_ADAPTER", "sidekiq").and_return("sidekiq")
    end

    it "starts the app generator with correct options" do
      expect(Decidim::Generators::AppGenerator).to receive(:start).with(
        [
          "development_app",
          "--app_name",
          "tasks_development_app",
          "--path",
          "..",
          "--recreate_db",
          "--seed_db",
          "--demo",
          "--profiling",
          "--locales",
          "en,ca,es",
          "--dev_ssl",
          "--queue=sidekiq"
        ]
      )

      task.execute
    end

    context "with the queue adapter passed through ENV" do
      let(:adapter_name) { "" }

      before do
        allow(ENV).to receive(:fetch).with("QUEUE_ADAPTER", "sidekiq").and_return(adapter_name)
      end

      it "starts the app generator with correct options" do
        expect(Decidim::Generators::AppGenerator).to receive(:start).with(
          [
            "development_app",
            "--app_name",
            "tasks_development_app",
            "--path",
            "..",
            "--recreate_db",
            "--seed_db",
            "--demo",
            "--profiling",
            "--locales",
            "en,ca,es",
            "--dev_ssl",
            "--queue=#{adapter_name}"
          ]
        )

        task.execute
      end

      context "with invalid queue adapter provided" do
        let(:adapter_name) { "async" }
        let(:main) { TOPLEVEL_BINDING.eval("self") }

        it "aborts the process" do
          expect(Decidim::Generators::AppGenerator).not_to receive(:start)
          expect(main).to receive(:abort).with("#{adapter_name} is not supported as a queue adapter") do |msg|
            raise SystemExit, msg
          end

          expect { task.execute }.to raise_error(SystemExit)
        end
      end
    end
  end
end
