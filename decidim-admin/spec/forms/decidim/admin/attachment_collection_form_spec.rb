# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe AttachmentCollectionForm do
    subject { described_class.from_params(attributes).with_context(context) }

    let(:organization) { create(:organization) }
    let(:collection_for) { create(:participatory_process, organization:) }
    let(:context) { { collection_for:, current_organization: organization } }
    let(:attributes) do
      {
        name: { "en" => "A collection" },
        description: { "en" => "A collection description" },
        key:
      }
    end

    describe "#key" do
      context "when the key is present" do
        let(:key) { "  collection-key  " }

        it "strips the surrounding whitespace" do
          expect(subject.key).to eq("collection-key")
        end
      end

      # The unique index on the key per holder considers an empty string a value,
      # so a blank key has to be stored as NULL; otherwise the second key-less
      # collection for the same holder would be rejected as a duplicate.
      context "when the key is blank" do
        let(:key) { "" }

        it "normalizes it to nil" do
          expect(subject.key).to be_nil
        end

        it "is valid" do
          expect(subject).to be_valid
        end

        it "allows another key-less collection for the same holder" do
          create(:attachment_collection, collection_for:, key: nil)

          expect(subject).to be_valid
        end
      end
    end
  end
end
