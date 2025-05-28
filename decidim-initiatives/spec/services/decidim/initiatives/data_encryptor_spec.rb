# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    describe DataEncryptor do
      let(:secret) { ::Faker::Hipster.word }
      let(:plain_text_payload) { "This is a test message" }
      let(:hash_payload) do
        {
          name_and_surname: ::Faker::Name.name,
          document_number: ::Faker::IdNumber.spanish_citizen_number,
          date_of_birth: ::Faker::Date.birthday(min_age: 18, max_age: 40).to_s,
          postal_code: ::Faker::Address.zip_code
        }
      end
      let(:encryptor) { described_class.new(secret:) }

      describe "encrypt" do
        it "encrypts plain data" do
          expect(encryptor.encrypt(plain_text_payload)).to be_present
        end

        it "encrypts hash data" do
          expect(encryptor.encrypt(hash_payload)).to be_present
        end
      end

      describe "decrypt" do
        let(:encrypted_plain_data) { encryptor.encrypt(plain_text_payload) }
        let(:encrypted_hash_data) { encryptor.encrypt(hash_payload) }

        it "decrypts plain data" do
          expect(encryptor.decrypt(encrypted_plain_data)).to eq(plain_text_payload)
        end

        it "decrypts hash data" do
          expect(encryptor.decrypt(encrypted_hash_data).with_indifferent_access).to eq(hash_payload.with_indifferent_access)
        end

        it "invalid data cannot be decrypted" do
          expect { encryptor.decrypt("wadus") }.to raise_error(ActiveSupport::MessageEncryptor::InvalidMessage)
        end
      end
    end
  end
end
