# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Elections
    describe BulletinBoardClient do
      subject { described_class.new(params) }

      let(:params) do
        {
          identification_private_key: identification_private_key,
          server: server,
          api_key: api_key
        }
      end

      let(:identification_private_key) { identification_private_key_content }
      let(:server) { "https://bb.example.org" }
      let(:api_key) { Random.urlsafe_base64(30) }

      let(:identification_private_key_content) { <<~EOK
        -----BEGIN RSA PRIVATE KEY-----
        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
        -----END RSA PRIVATE KEY-----
EOK
      }

      it { is_expected.to be_configured }

      it "has an identification public key" do
        expect(subject.public_key).to be_public
      end

      context "when private key is a path to a file" do
        around do |example|
          Tempfile.create do |file|
            file << identification_private_key_content
            file.flush
            @temp_file_path = file.path
            example.call
          end
        end

        let(:identification_private_key) { @temp_file_path }

        it { is_expected.to be_configured }

        it "has an identification public key" do
          expect(subject.public_key).to be_public
        end
      end

      context "when private key is not present" do
        let(:identification_private_key) { "" }

        it { is_expected.not_to be_configured }

        it "doesn't have an identification public key" do
          expect(subject.public_key).to be_nil
        end
      end

      context "when server is not present" do
        let(:server) { "" }

        it { is_expected.not_to be_configured }
      end

      context "when api_key is not present" do
        let(:api_key) { "" }

        it { is_expected.not_to be_configured }
      end
    end
  end
end
