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
    end
  end
end
