# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe UpdateAttachmentCollection do
    subject { described_class.call(attachment_collection, form) }

    let(:user) { create(:user, :admin) }
    let(:attachment_collection) { create(:attachment_collection, collection_for: create(:participatory_process)) }
    let(:key) { "new-key" }
    let(:errors) { ActiveModel::Errors.new(AttachmentCollectionForm.new) }
    let(:form) do
      instance_double(
        AttachmentCollectionForm,
        name: {
          "en" => "A collection"
        },
        description: {
          "en" => "A collection description"
        },
        weight: 1,
        key:,
        current_user: user,
        errors:
      )
    end

    before do
      allow(form).to receive(:invalid?).and_return(false)
    end

    describe "when valid" do
      it "broadcasts :ok and updates the collection" do
        expect { subject }.to broadcast(:ok)
      end

      it "updates the attributes from the form" do
        subject
        attachment_collection.reload
        expect(attachment_collection.name.except("machine_translations")).to eq({ "en" => "A collection" })
        expect(attachment_collection.description.except("machine_translations")).to eq({ "en" => "A collection description" })
        expect(attachment_collection.weight).to eq(1)
      end

      context "when the form provides a key" do
        it "saves the key from the form" do
          subject
          attachment_collection.reload
          expect(attachment_collection.key).to eq("new-key")
        end
      end

      context "when the form does not provide a key" do
        # The admin edit form does not submit the key, so editing a collection
        # created through the API must not erase the key used to look it up.
        let(:key) { nil }

        it "preserves the existing key" do
          original_key = attachment_collection.key
          subject
          attachment_collection.reload
          expect(attachment_collection.key).to eq(original_key)
        end
      end
    end

    describe "when the key is already taken for the same collection holder" do
      # The form validation is a check-then-insert, so a concurrent request can
      # still reach the database constraint. The command must turn that into a
      # form error instead of letting the exception bubble up.
      let(:key) { "taken-key" }

      before do
        create(:attachment_collection, collection_for: attachment_collection.collection_for, key:)
      end

      it "broadcasts :invalid instead of raising" do
        expect { subject }.to broadcast(:invalid)
      end

      it "adds the taken error to the form" do
        subject

        expect(errors[:key]).to eq(["has already been taken"])
      end

      it "keeps the original key" do
        original_key = attachment_collection.key

        subject

        attachment_collection.reload
        expect(attachment_collection.key).to eq(original_key)
      end
    end

    describe "when invalid" do
      before do
        allow(form).to receive(:invalid?).and_return(true)
      end

      it "broadcasts invalid" do
        expect { subject }.to broadcast(:invalid)
      end
    end
  end
end
