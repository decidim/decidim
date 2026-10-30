# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Dev
    describe DummyResource do
      subject { dummy_resource }

      let(:dummy_resource) { create(:dummy_resource) }

      it { is_expected.to be_valid }

      it "has an association of nested_dummy_resources" do
        nested = create(:nested_dummy_resource, dummy_resource:)

        expect(dummy_resource.nested_dummy_resources).to eq([nested])
      end

      it "uses the nested_dummy_resources association as the inverse of the dummy resource" do
        create(:nested_dummy_resource, dummy_resource:)

        expect(dummy_resource.nested_dummy_resources.first.dummy_resource).to be(dummy_resource)
      end

      it "does not destroy the nested resources when the dummy resource is soft deleted" do
        nested = create(:nested_dummy_resource, dummy_resource:)

        dummy_resource.destroy

        expect(Decidim::Dev::NestedDummyResource.exists?(nested.id)).to be(true)
      end

      it "destroys the nested resources when the dummy resource is permanently destroyed" do
        nested = create(:nested_dummy_resource, dummy_resource:)

        dummy_resource.really_destroy!

        expect(Decidim::Dev::NestedDummyResource.exists?(nested.id)).to be(false)
      end

      it "destroys the nested resources added after the association was loaded" do
        nested = create(:nested_dummy_resource, dummy_resource:)
        dummy_resource.nested_dummy_resources.to_a

        # Another instance adds a child, leaving the cached association target stale.
        other = create(:nested_dummy_resource, dummy_resource: described_class.find(dummy_resource.id))

        dummy_resource.really_destroy!

        expect(Decidim::Dev::NestedDummyResource.exists?(nested.id)).to be(false)
        expect(Decidim::Dev::NestedDummyResource.exists?(other.id)).to be(false)
      end
    end
  end
end
