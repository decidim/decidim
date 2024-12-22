# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe AttributeEncryptor do
    around do |example|
      # Clear the cached cryptor instance because the specs are testing the
      # utility under different configurations which can affect the
      # `ActiveSupport::MessageEncryptor` instance.
      described_class.remove_instance_variable(:@cryptor) if described_class.instance_variable_defined?(:@cryptor)
      example.run
      described_class.remove_instance_variable(:@cryptor) if described_class.instance_variable_defined?(:@cryptor)
    end

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
              ActiveSupport::MessageEncryptor::InvalidMessage
            )
          end
        end
      end

      context "when the passed value is a correctly encrypted string" do
        let(:value) { "+7Mv1nXW5obXnkaDUW+9Bqg=--qgiVKMTttTRKwd6f--Bx1yDcuZYwNv7Oj55MnE3g==" }

        before do
          # Temporarily change the secret so that it matches the secret used
          # when encrypting the value.
          allow(Rails.application).to receive(:secret_key_base).and_return("testsecret")
        end

        it "returns the decrypted value" do
          expect(described_class.decrypt(value)).to eq("Decidim")
        end

        it "runs in a performant way when called multiple times consecutively" do
          start = Time.current
          1000.times { described_class.decrypt(value) }

          # This actually takes a lot less time but the idea of the spec is to
          # check that this runs in a performant way.
          expect(Time.current - start).to be < 1
        end
      end
    end
  end
end
