# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe CreateAttachmentCollection do
    subject { described_class.call(form, collection_for) }

    let(:user) { create(:user, :admin) }
    let(:collection_for) { create(:participatory_process) }
    let(:key) { "collection-key" }
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
      it "broadcasts :ok and creates the collection" do
        expect { subject }.to broadcast(:ok)

        expect(Decidim::AttachmentCollection.count).to eq(1)
      end

      it "creates the collection with the attributes from the form" do
        subject

        collection = Decidim::AttachmentCollection.first
        expect(collection.collection_for).to eq(collection_for)
        expect(collection.name.except("machine_translations")).to eq({ "en" => "A collection" })
        expect(collection.description.except("machine_translations")).to eq({ "en" => "A collection description" })
        expect(collection.weight).to eq(1)
        expect(collection.key).to eq(key)
      end

      it "creates an action log for the current user" do
        expect { subject }.to change(Decidim::ActionLog, :count).by(1)

        expect(Decidim::ActionLog.last.user).to eq(user)
      end
    end

    describe "when the key is already taken for the same collection holder" do
      # The form validation is a check-then-insert, so a concurrent request can
      # still reach the database constraint. The command must turn that into a
      # form error instead of letting the exception bubble up.
      let(:key) { "taken-key" }

      before do
        create(:attachment_collection, collection_for:, key:)
      end

      it "broadcasts :invalid instead of raising" do
        expect { subject }.to broadcast(:invalid)
      end

      it "adds the taken error to the form" do
        subject

        expect(errors[:key]).to eq(["has already been taken"])
      end

      it "does not create the collection" do
        expect { subject }.not_to change(Decidim::AttachmentCollection, :count)
      end
    end

    describe "when the key is taken for a different collection holder" do
      # Uniqueness is scoped to the parent, so the same key in another space is fine.
      let(:key) { "shared-key" }

      before do
        create(:attachment_collection, collection_for: create(:participatory_process), key:)
      end

      it "broadcasts :ok" do
        expect { subject }.to broadcast(:ok)
      end
    end
  end
end
