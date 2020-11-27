# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Authorization do
    let(:authorization) { build(:authorization) }

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
      let!(:authorization) { create(:authorization, :granted, metadata: { foo: "bar" }) }
      let(:database_metadata) do
        JSON.parse(
          ActiveRecord::Base.connection.select_one(
            "SELECT metadata FROM #{described_class.table_name} WHERE id = #{authorization.id}"
          )["metadata"]
        )
      end
      let(:expected_foo) { "bar" }

      shared_examples_for "encrypted authorization metadata" do
        it "encrypts the metadata to the database" do
          expect(
            Decidim::AttributeEncryptor.decrypt(database_metadata["foo"])
          ).to eq(expected_foo)
        end

        it "decrypts the final values automatically" do
          final = Decidim::Authorization.find(authorization.id)
          expect(final.metadata["foo"]).to eq(expected_foo)
        end
      end

      it_behaves_like "encrypted authorization metadata"

      context "when storing with update!" do
        let(:expected_foo) { "baz" }

        before do
          authorization.update!(metadata: { foo: "baz" })
        end

        it_behaves_like "encrypted authorization metadata"
      end

      context "when storing with attribute update" do
        let(:expected_foo) { "biz" }

        before do
          authorization.metadata = { foo: "biz" }
          authorization.save!
        end

        it_behaves_like "encrypted authorization metadata"
      end

      context "when storing with attributes=" do
        let(:expected_foo) { "buz" }

        before do
          authorization.attributes = { metadata: { foo: "buz" } }
          authorization.save!
        end

        it_behaves_like "encrypted authorization metadata"
      end
    end

    context "with verification metadata" do
      let!(:authorization) { create(:authorization, :pending, verification_metadata: { foo: "bar" }) }
      let(:database_metadata) do
        JSON.parse(
          ActiveRecord::Base.connection.select_one(
            "SELECT verification_metadata FROM #{described_class.table_name} WHERE id = #{authorization.id}"
          )["verification_metadata"]
        )
      end
      let(:expected_foo) { "bar" }

      shared_examples_for "encrypted authorization verification metadata" do
        it "encrypts the metadata to the database" do
          expect(
            Decidim::AttributeEncryptor.decrypt(database_metadata["foo"])
          ).to eq(expected_foo)
        end

        it "decrypts the final values automatically" do
          final = Decidim::Authorization.find(authorization.id)
          expect(final.verification_metadata["foo"]).to eq(expected_foo)
        end
      end

      it_behaves_like "encrypted authorization verification metadata"

      context "when storing with update!" do
        let(:expected_foo) { "baz" }

        before do
          authorization.update!(verification_metadata: { foo: "baz" })
        end

        it_behaves_like "encrypted authorization verification metadata"
      end

      context "when storing with attribute update" do
        let(:expected_foo) { "biz" }

        before do
          authorization.verification_metadata = { foo: "biz" }
          authorization.save!
        end

        it_behaves_like "encrypted authorization verification metadata"
      end

      context "when storing with attributes=" do
        let(:expected_foo) { "buz" }

        before do
          authorization.attributes = { verification_metadata: { foo: "buz" } }
          authorization.save!
        end

        it_behaves_like "encrypted authorization verification metadata"
      end
    end
  end
end
