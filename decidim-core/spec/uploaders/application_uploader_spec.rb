# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ApplicationUploader do
    subject { described_class.new(model, mounted_as) }

    let(:model) { create(:organization) }
    let(:mounted_as) { :open_data_file }

    describe "#protocol_options" do
      shared_context "with force_ssl enabled" do
        before do
          allow(Rails.application.config).to receive(:force_ssl).and_return(true)
        end
      end

      shared_context "with PORT environment variable" do
        before do
          allow(ENV).to receive(:fetch).with("PORT", instance_of(Integer)).and_return(local_port)
        end
      end

      shared_examples "development local storage protocol options" do
        it "returns a hash containing the port only" do
          expect(subject.protocol_options).to eq({ port: 3000 })
        end

        context "when the PORT environment variable is defined as 80" do
          include_context "with PORT environment variable"

          let(:local_port) { 80 }

          it "returns an empty hash" do
            expect(subject.protocol_options).to eq({})
          end
        end

        context "when force_ssl is enabled" do
          include_context "with force_ssl enabled"

          it "returns a hash containing the port and protocol" do
            expect(subject.protocol_options).to eq({ port: 3000, protocol: "https" })
          end

          context "and the PORT environment variable is defined as 3001" do
            include_context "with PORT environment variable"

            let(:local_port) { 3001 }

            it "returns a hash containing the port and protocol" do
              expect(subject.protocol_options).to eq({ port: 3001, protocol: "https" })
            end
          end

          context "and the PORT environment variable is defined as 443" do
            include_context "with PORT environment variable"

            let(:local_port) { 443 }

            it "returns a hash containing the protocol only" do
              expect(subject.protocol_options).to eq({ protocol: "https" })
            end
          end
        end
      end

      context "with test environment" do
        it_behaves_like "development local storage protocol options"
      end

      context "with development environment" do
        before do
          allow(Rails.env).to receive(:development?).and_return(true)
        end

        it_behaves_like "development local storage protocol options"
      end

      context "with production environment" do
        before do
          allow(Rails.env).to receive(:development?).and_return(false)
          allow(Rails.env).to receive(:test?).and_return(false)
        end

        it "returns an empty hash by default" do
          expect(subject.protocol_options).to eq({})
        end

        context "and the PORT environment variable is defined as 443" do
          include_context "with PORT environment variable"

          let(:local_port) { 443 }

          it "returns a hash containing the protocol only" do
            expect(subject.protocol_options).to eq({ protocol: "https" })
          end
        end

        context "and the PORT environment variable is defined as 8080" do
          include_context "with PORT environment variable"

          let(:local_port) { 8080 }

          it "returns a hash containing the port" do
            expect(subject.protocol_options).to eq({ port: 8080 })
          end
        end

        context "and force_ssl is enabled" do
          include_context "with force_ssl enabled"

          it "returns a hash containing the protocol only" do
            expect(subject.protocol_options).to eq({ protocol: "https" })
          end

          context "and the PORT environment variable is defined as 8080" do
            include_context "with PORT environment variable"

            let(:local_port) { 8080 }

            it "returns a hash containing the port and protocol" do
              expect(subject.protocol_options).to eq({ port: 8080, protocol: "https" })
            end
          end
        end
      end

      context "with CDN host defined in the secrets" do
        let(:cdn_host) { "https://cdn.example.org" }

        before do
          allow(Rails.application.secrets).to receive(:dig).with(:storage, :cdn_host).and_return(cdn_host)
        end

        it "returns a hash containing the host only" do
          expect(subject.protocol_options).to eq({ host: "https://cdn.example.org" })
        end
      end
    end
  end
end
