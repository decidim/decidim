# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe UrlOptionResolver do
    let(:resolver) { described_class.new }

    describe "#protocol" do
      subject { resolver.protocol }

      it { is_expected.to eq("http") }

      context "when force_ssl is enabled for the application" do
        before { allow(Rails.application.config).to receive(:force_ssl).and_return(true) }

        it { is_expected.to eq("https") }
      end

      context "when the port is configured as 443" do
        before { allow(resolver).to receive(:port).and_return(443) }

        it { is_expected.to eq("https") }
      end
    end

    describe "#host" do
      subject { resolver.host }

      it { is_expected.to eq("localhost") }

      context "when the environment is development" do
        before { allow(Rails.env).to receive(:development?).and_return(true) }

        it { is_expected.to eq("localhost") }
      end

      context "when the environment is not development or test" do
        before do
          allow(Rails.env).to receive(:local?).and_return(false)
        end

        it { is_expected.to be_nil }
      end

      context "when the host is defined in the HOSTNAME environment variable" do
        before { allow(ENV).to receive(:fetch).with("HOSTNAME", "localhost").and_return("custom.host") }

        it { is_expected.to eq("custom.host") }
      end
    end

    describe "#port" do
      subject { resolver.port }

      it { is_expected.to eq(Capybara.server_port) }

      context "when the environment is development" do
        before { allow(Rails.env).to receive(:development?).and_return(true) }

        it { is_expected.to eq(3000) }
      end

      context "when the port is defined in the PORT environment variable" do
        before { allow(ENV).to receive(:fetch).with("HTTP_PORT", instance_of(Integer)).and_return("8080") }

        it { is_expected.to eq(8080) }
      end

      context "with production configuration" do
        before do
          allow(Rails.env).to receive(:development?).and_return(false)
          allow(Rails.env).to receive(:test?).and_return(false)
        end

        it { is_expected.to eq(80) }

        context "and force_ssl is enabled for the application" do
          before { allow(Rails.application.config).to receive(:force_ssl).and_return(true) }

          it { is_expected.to eq(443) }
        end
      end
    end

    describe "#default_port?" do
      subject { resolver.default_port? }

      it { is_expected.to be(false) }

      context "when the port is 80" do
        before { allow(resolver).to receive(:port).and_return(80) }

        it { is_expected.to be(true) }
      end

      context "when the port is 443" do
        before { allow(resolver).to receive(:port).and_return(443) }

        it { is_expected.to be(true) }
      end
    end

    describe "#options" do
      subject { resolver.options }

      it { is_expected.to eq(host: "localhost", port: Capybara.server_port) }

      context "when the protocol is https" do
        before { allow(resolver).to receive(:protocol).and_return("https") }

        it { is_expected.to eq(host: "localhost", port: Capybara.server_port, protocol: "https") }
      end

      context "when the port is 80" do
        before { allow(resolver).to receive(:port).and_return(80) }

        it { is_expected.to eq(host: "localhost") }
      end

      context "when the port is 443" do
        before { allow(resolver).to receive(:port).and_return(443) }

        it { is_expected.to eq(host: "localhost", protocol: "https") }
      end

      context "when the host is not defined" do
        before { allow(resolver).to receive(:host).and_return(nil) }

        it { is_expected.to eq(port: Capybara.server_port) }
      end
    end
  end
end
