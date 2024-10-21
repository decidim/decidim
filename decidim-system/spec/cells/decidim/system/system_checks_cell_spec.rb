# frozen_string_literal: true

require "spec_helper"

describe Decidim::System::SystemChecksCell, type: :cell do
  controller Decidim::System::DashboardController

  subject { my_cell.call(:show) }

  let(:my_cell) { cell("decidim/system/system_checks", nil) }

  describe "#generated_secret_key" do
    it "generates it well" do
      generated_secret_key = my_cell.send(:generated_secret_key)
      expect(generated_secret_key.length).to eq 128
    end

    it "does not generates two times the same string" do
      generated_secret_key1 = my_cell.send(:generated_secret_key)
      generated_secret_key2 = my_cell.send(:generated_secret_key)
      expect(generated_secret_key1).not_to eq generated_secret_key2
    end
  end

  describe "secret_key_check" do
    before do
      allow(Rails.application).to receive(:secret_key_base).and_return(secret_key)
    end

    context "when the secret key is correct" do
      let(:secret_key) { "98a143987c91e79d9b587c65f720c030a91131dd70427a305706d9d6652b8e97d1498b1dd329669edfc9302d03039303425732cdb3c1ee8429e2d58dee179c55" }

      it "shows the success message" do
        expect(subject).to have_content "The secret key is configured correctly"
      end
    end

    context "when the secret key is empty" do
      let(:secret_key) { "" }

      it "shows the error message" do
        expect(subject).to have_content "The secret key is not defined correctly"
        expect(subject).to have_content "Please save to the SECRET_KEY_BASE environment variable and restart the server"
      end
    end

    context "when the secret key is nil" do
      let(:secret_key) { nil }

      it "shows the error message" do
        expect(subject).to have_content "The secret key is not defined correctly"
        expect(subject).to have_content "Please save to the SECRET_KEY_BASE environment variable and restart the server"
      end
    end
  end

  describe "active_job_queue_check" do
    before do
      allow(Rails.application.config.active_job).to receive(:queue_adapter).and_return(active_job_queue)
    end

    context "when the ActiveJob queue is correct" do
      let(:active_job_queue) { :sidekiq }

      it "shows the success message" do
        expect(subject).to have_content "The ActiveJob queue is configured correctly"
      end
    end

    context "when the ActiveJob queue is incorrect" do
      let(:active_job_queue) { :async }

      it "shows the error message" do
        expect(subject).to have_content "The ActiveJob queue is not configured."
        expect(subject).to have_content "This is not a recommended setup for production"
        expect(subject).to have_link("Decidim Documentation", href: "https://docs.decidim.org/en/develop/services/activejob")
      end
    end
  end
end
