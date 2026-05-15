# frozen_string_literal: true

require "spec_helper"

shared_examples_for "attachable interface" do
  let!(:attached_to) { model }
  let!(:attachments) { create_list(:attachment, 3, attached_to:) }

  describe "attachments" do
    let(:query) { "{ attachments { url } }" }

    it "includes the attachment urls" do
      attachment_urls = response["attachments"].map { |attachment| attachment["url"] }
      expect(attachment_urls).to include_blob_urls(*attachments.map(&:file).map(&:blob))
    end
  end
end

shared_examples_for "attachable collection interface with attachment" do
  context "when the model has an attachment collection" do
    let!(:attachment_collection) { create(:attachment_collection, collection_for: model) }

    describe "attachment_collections" do
      let(:query) { '{ attachmentCollections { name { translation(locale:"en") } } }' }

      it "includes the name of collection" do
        expect(response["attachmentCollections"][0]["name"]["translation"]).to include(translated(attachment_collection.name))
      end
    end

    describe "attachments" do
      let(:attached_to) { attachment_collection }
      let(:query) { "{ attachmentCollections { attachments { url } } }" }

      include_examples "attachable interface" do
        let!(:attached_to) { attachment_collection }
      end
    end
  end
end
