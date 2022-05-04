# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe AttributeEncryptor do
    describe ".decrypt" do
      context "when the passed value is blank" do
        let(:value) { "" }

        it "returns nil" do
          expect(described_class.decrypt(value)).to be_nil
        end
      end

      context "when the passed value is a hash" do
        let(:value) { { "foo" => "bar" } }

        it "returns the original value" do
          expect(described_class.decrypt(value)).to eq(value)
        end
      end

      context "when the passed value is an Integer" do
        let(:value) { 123 }

        it "returns the original value" do
          expect(described_class.decrypt(value)).to eq(123)
        end
      end

      context "when the passed value is an a test double" do
        let(:value) { double }

        it "returns the original value" do
          expect(described_class.decrypt(value)).to be(value)
        end
      end

      context "when the passed value is an invalid encrypted string" do
        let(:value) { "foobar" }

        it "raises ActiveSupport::MessageEncryptor::InvalidMessage" do
          expect { described_class.decrypt(value) }.to raise_error(
            ActiveSupport::MessageEncryptor::InvalidMessage
          )
        end

        context "with Rails 5.1 defaults" do
          before do
            allow(ActiveSupport::MessageEncryptor).to receive(
              :use_authenticated_message_encryption
            ).and_return(false)
          end

          it "raises ActiveSupport::MessageVerifier::InvalidSignature" do
            expect { described_class.decrypt(value) }.to raise_error(
              ActiveSupport::MessageVerifier::InvalidSignature
            )
          end
        end
      end

      context "when the passed value is a correctly encrypted string" do
        let(:value) { "+7Mv1nXW5obXnkaDUW+9Bqg=--qgiVKMTttTRKwd6f--Bx1yDcuZYwNv7Oj55MnE3g==" }

        before do
          # Temporarily change the secret so that it matches the secret used
          # when encrypting the value.
          allow(Rails.application.secrets).to receive(
            :secret_key_base
          ).and_return("testsecret")
        end

        it "returns the decrypted value" do
          expect(described_class.decrypt(value)).to eq("Decidim")
        end
      end
    end
  end
end
