# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe AttachmentCollection do
    subject { attachment_collection }

    let(:attachment_collection) { build(:attachment_collection) }

    it { is_expected.to be_valid }

    context "with the key" do
      # Uniqueness is enforced by the partial unique index added in
      # decidim-core/db/migrate/20261112100239_add_unique_key_to_attachment_collection.rb
      let(:collection_for) { create(:participatory_process) }

      it "rejects a key already used by another collection for the same holder" do
        create(:attachment_collection, collection_for:, key: "shared-key")

        expect do
          create(:attachment_collection, collection_for:, key: "shared-key")
        end.to raise_error(ActiveRecord::RecordNotUnique)
      end

      it "allows the same key for a different holder" do
        expect do
          create(:attachment_collection, collection_for: create(:participatory_process), key: "shared-key")
        end.not_to raise_error
      end

      it "allows several collections without a key for the same holder" do
        expect do
          2.times { create(:attachment_collection, collection_for:, key: nil) }
        end.not_to raise_error
      end

      it "creates the unique index for the key per holder" do
        index = ActiveRecord::Base.connection.indexes(:decidim_attachment_collections).find do |current|
          current.name == "index_attachment_collections_unique_key_per_parent"
        end

        expect(index).to be_present
        expect(index.columns).to eq(%w(collection_for_type collection_for_id key))
        expect(index.unique).to be(true)
      end
    end
  end
end
