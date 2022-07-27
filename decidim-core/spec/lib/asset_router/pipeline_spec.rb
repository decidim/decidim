# frozen_string_literal: true

require "spec_helper"

module Decidim::AssetRouter
  describe Pipeline do
    subject { router }

    let(:router) { described_class.new(asset, model:) }
    let(:asset) { "media/images/decidim-logo.svg" }
    let(:model) { nil }

    let(:correct_asset_path) { ActionController::Base.helpers.asset_pack_path(asset) }

    describe "#url" do
      subject { router.url }

      it { is_expected.to eq("//localhost:#{Capybara.server_port}#{correct_asset_path}") }

      context "when using the default HTTP port" do
        before do
          allow(ENV).to receive(:fetch).and_call_original
          allow(ENV).to receive(:fetch).with("PORT", Capybara.server_port).and_return(80)
        end

        it { is_expected.to eq("//localhost#{correct_asset_path}") }
      end

      context "when the system is configured to be served over HTTPS" do
        before do
          allow(Rails.application.config).to receive(:force_ssl).and_return(true)
        end

        it { is_expected.to eq("https://localhost:#{Capybara.server_port}#{correct_asset_path}") }

        context "and using the default HTTPS port" do
          before do
            allow(ENV).to receive(:fetch).and_call_original
            allow(ENV).to receive(:fetch).with("PORT", Capybara.server_port).and_return(443)
          end

          it { is_expected.to eq("https://localhost#{correct_asset_path}") }
        end
      end

      context "when the host cannot be resolved" do
        before do
          allow(Rails.env).to receive(:test?).and_return(false)
        end

        it { is_expected.to eq(correct_asset_path) }
      end

      context "with custom host configuration" do
        before do
          allow(ENV).to receive(:fetch).and_call_original
          allow(ENV).to receive(:fetch).with("HOSTNAME", "localhost").and_return("example.org")
        end

        it { is_expected.to eq("//example.org:#{Capybara.server_port}#{correct_asset_path}") }
      end

      context "with a custom asset host configured for the Rails application" do
        before do
          allow(Rails.configuration.action_controller).to receive(:asset_host).and_return("cdn.example.org")
        end

        it { is_expected.to eq("//cdn.example.org:#{Capybara.server_port}#{correct_asset_path}") }
      end

      context "with a model" do
        let(:model) { create(:user) }

        it { is_expected.to eq("//#{model.organization.host}:#{Capybara.server_port}#{correct_asset_path}") }

        context "and a custom assets host configured for the Rails application" do
          before do
            allow(Rails.configuration.action_controller).to receive(:asset_host).and_return("cdn.example.org")
          end

          it { is_expected.to eq("//cdn.example.org:#{Capybara.server_port}#{correct_asset_path}") }
        end

        context "when given an organization as the model" do
          let(:model) { create(:organization) }

          it { is_expected.to eq("//#{model.host}:#{Capybara.server_port}#{correct_asset_path}") }
        end
      end
    end
  end
end
