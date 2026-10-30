# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Dev
    describe NestedDummyResource do
      subject { nested_dummy_resource }

      let(:dummy_resource) { create(:dummy_resource) }
      let(:nested_dummy_resource) { create(:nested_dummy_resource, dummy_resource:) }

      it { is_expected.to be_valid }

      it "has an association of dummy_resource" do
        expect(nested_dummy_resource.dummy_resource).to be(dummy_resource)
      end

      it "uses the nested_dummy_resources association as the inverse of the dummy resource" do
        expect(dummy_resource.nested_dummy_resources).to eq([nested_dummy_resource])
        expect(nested_dummy_resource.dummy_resource.nested_dummy_resources.first).to be(nested_dummy_resource)
      end
    end
  end
end
