# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Authorization do
    let(:authorization) { build(:authorization) }

    shared_examples_for "encrypted authorization metadata decryption" do
      it "encrypts the metadata to the database" do
        expect(
          Decidim::AttributeEncryptor.decrypt(database_metadata["foo"])
        ).to eq(
          ActiveSupport::JSON.encode(expected_foo)
        )
      end

      it "decrypts the final values automatically" do
        final = Decidim::Authorization.find(authorization.id)
        data = final.send(authorization_metadata_key)
        expect(data["foo"]).to eq(expected_foo)
      end
    end

    shared_context "with encrypted authorization metadata" do
      let(:authorization_metadata) { { foo: "bar" } }
      let!(:authorization) do
        data = {}
        data[authorization_metadata_key] = authorization_metadata
        create(:authorization, authorization_status, data)
      end
      let(:database_metadata) do
        JSON.parse(
          ActiveRecord::Base.connection.select_one(
            "SELECT #{authorization_metadata_key} FROM #{described_class.table_name} WHERE id = #{authorization.id}"
          )[authorization_metadata_key.to_s]
        )
      end
      let(:expected_foo) { "bar" }

      it_behaves_like "encrypted authorization metadata decryption"

      context "when storing with update!" do
        let(:expected_foo) { "baz" }
        let(:authorization_metadata) { { foo: "baz" } }

        it_behaves_like "encrypted authorization metadata decryption"
      end

      context "when storing with attribute update" do
        let(:expected_foo) { "biz" }
        let(:authorization_metadata) { { foo: "biz" } }

        before do
          authorization.send("#{authorization_metadata_key}=", authorization_metadata)
          authorization.save!
        end

        it_behaves_like "encrypted authorization metadata decryption"
      end

      context "when storing with attributes=" do
        let(:expected_foo) { "buz" }
        let(:authorization_metadata) { { foo: "buz" } }

        before do
          attributes = {}
          attributes[authorization_metadata_key] = authorization_metadata

          authorization.attributes = attributes
          authorization.save!
        end

        it_behaves_like "encrypted authorization metadata decryption"
      end
    end

    it "is valid" do
      expect(authorization).to be_valid
    end

    context "when leaving verification data around" do
      let(:authorization) do
        build(:authorization, verification_metadata: { sensible_stuff: "123456" })
      end

      it "is not valid" do
        expect(authorization).not_to be_valid
      end
    end

    context "when verification is granted" do
      let!(:authorization) { create(:authorization, name: "dummy_authorization_handler") }

      it "has renewable? method" do
        expect(authorization).to be_renewable
      end

      it "has metadata_cell" do
        expect(authorization.metadata_cell).to be_kind_of String
      end
    end

    context "with metadata" do
      include_context "with encrypted authorization metadata" do
        let(:authorization_metadata_key) { :metadata }
        let(:authorization_status) { :granted }
      end
    end

    context "with verification metadata" do
      include_context "with encrypted authorization metadata" do
        let(:authorization_metadata_key) { :verification_metadata }
        let(:authorization_status) { :pending }
      end
    end
  end
end
