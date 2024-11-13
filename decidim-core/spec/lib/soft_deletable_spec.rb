# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe SoftDeletable do
    let(:resource) { create(:dummy_resource) }

    describe "#trashed?" do
      context "when deleted_at is nil" do
        it "returns false" do
          expect(resource.deleted?).to be false
        end
      end

      context "when deleted_at is set" do
        before do
          resource.update!(deleted_at: Time.current)
        end

        it "returns true" do
          expect(resource.deleted?).to be true
        end
      end
    end

    describe "#trash!" do
      it "sets deleted_at to current time" do
        expect { resource.destroy! }.to change(resource, :deleted_at).from(nil)
      end
    end

    describe "#restore!" do
      before do
        resource.update!(deleted_at: Time.current)
      end

      it "clears the deleted_at field" do
        expect { resource.restore! }.to change(resource, :deleted_at).to(nil)
      end
    end

    describe ".not_trashed" do
      let!(:resource1) { create(:dummy_resource) }
      let!(:resource2) { create(:dummy_resource, deleted_at: Time.current) }

      it "returns only resources that are not deleted" do
        expect(Decidim::Dev::DummyResource).to include(resource1)
        expect(Decidim::Dev::DummyResource).not_to include(resource2)
      end
    end

    describe ".trashed" do
      let!(:resource1) { create(:dummy_resource, deleted_at: Time.current) }
      let!(:resource2) { create(:dummy_resource) }

      it "returns only trashed resources" do
        expect(Decidim::Dev::DummyResource.only_deleted).to include(resource1)
        expect(Decidim::Dev::DummyResource.only_deleted).not_to include(resource2)
      end
    end
  end
end
