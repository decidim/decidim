# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe TaxonomyItemForm do
    subject { described_class.from_params(attributes).with_context(context) }

    let(:organization) { create(:organization) }
    let(:item_name) { attributes_for(:taxonomy)[:name] }
    let(:root_taxonomy) { create(:taxonomy, organization:) }
    let(:parent) { create(:taxonomy, organization:, parent: root_taxonomy) }
    let(:parent_id) { parent.id }
    let(:attributes) do
      {
        "item_name" => item_name,
        "parent_id" => parent_id
      }
    end
    let(:context) do
      {
        current_organization: organization
      }
    end

    context "when everything is OK" do
      it { is_expected.to be_valid }
    end

    context "when item_name is not present" do
      let(:item_name) { { "en" => "" } }

      it { is_expected.to be_invalid }
    end

    context "when parent_id is not present" do
      let(:parent_id) { nil }

      it { is_expected.to be_invalid }
    end

    describe "#item_name" do
      it "returns the item_name" do
        expect(subject.item_name).to eq(item_name)
      end
    end

    describe "#parent_id" do
      it "returns the parent_id" do
        expect(subject.parent_id).to eq(parent_id)
      end
    end

    describe ".from_params" do
      let(:params) do
        {
          "taxonomy" => { "item_name_en" => "Test item" },
          "parent_id" => parent.id
        }
      end

      it "creates a form with the correct attributes" do
        form = described_class.from_params(params).with_context(context)
        expect(form.item_name).to eq({ "en" => "Test item" })
        expect(form.parent_id).to eq(parent.id)
      end
    end

    describe "#name" do
      it "returns the item_name" do
        expect(subject.name).to eq(subject.item_name)
      end
    end
  end
end
