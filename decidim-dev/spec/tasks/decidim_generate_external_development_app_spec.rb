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
    end
  end
end
