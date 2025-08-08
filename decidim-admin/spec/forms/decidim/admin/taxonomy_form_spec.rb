# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe TaxonomyForm do
    subject { described_class.from_params(attributes).with_context(context) }

    let(:organization) { create(:organization) }
    let(:name) { attributes_for(:taxonomy)[:name] }
    let(:attributes) { { name: } }
    let(:context) do
      {
        current_organization: organization
      }
    end

    context "when everything is OK" do
      it { is_expected.to be_valid }
    end

    context "when name is not present" do
      let(:name) { { "en" => "" } }

      it { is_expected.to be_invalid }
    end

    describe "#name" do
      it "returns the name" do
        expect(subject.name).to eq(name)
      end
    end

    describe "#organization" do
      it "returns the current organization" do
        expect(subject.organization).to eq(organization)
      end
    end

    describe "#parent_id" do
      it "returns nil" do
        expect(subject.parent_id).to be_nil
      end
    end
  end
end
