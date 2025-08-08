# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe TaxonomyFilterForm do
    subject { described_class.from_params(attributes).with_context(context) }

    let(:organization) { create(:organization) }
    let(:attributes) { { root_taxonomy_id:, taxonomy_items: } }
    let(:root_taxonomy_id) { root_taxonomy.id }
    let(:root_taxonomy) { create(:taxonomy, organization:) }
    let(:taxonomy_items) { [taxonomy_item.id] }
    let(:taxonomy_child) { create(:taxonomy, parent: root_taxonomy, organization:) }
    let(:taxonomy_grandchild) { create(:taxonomy, parent: taxonomy_child, organization:) }
    let(:taxonomy_item) { create(:taxonomy, parent: taxonomy_grandchild, organization:) }
    let(:context) do
      {
        current_organization: organization
      }
    end

    context "when everything is OK" do
      it { is_expected.to be_valid }

      it "returns the root taxonomy" do
        expect(subject.root_taxonomy).to eq(root_taxonomy)
      end

      it "returns the items collection" do
        expect(subject.items_collection).to eq(
          [
            Decidim::Admin::TaxonomyFilterForm::Item.new(
              name: translated(taxonomy_child.name),
              value: taxonomy_child.id,
              children: [
                Decidim::Admin::TaxonomyFilterForm::Item.new(
                  name: translated(taxonomy_grandchild.name),
                  value: taxonomy_grandchild.id,
                  children: [
                    Decidim::Admin::TaxonomyFilterForm::Item.new(
                      name: translated(taxonomy_item.name),
                      value: taxonomy_item.id,
                      children: []
                    )
                  ]
                )
              ]
            )
          ]
        )
      end

      it "returns the filter items" do
        expect(subject.filter_items.map(&:taxonomy_item_id)).to contain_exactly(taxonomy_item.id)
      end

      context "when grandchild is selected" do
        let(:taxonomy_items) { [taxonomy_grandchild.id] }

        it { is_expected.to be_valid }

        it "returns the filter items" do
          expect(subject.filter_items.map(&:taxonomy_item_id)).to contain_exactly(taxonomy_grandchild.id)
        end
      end
    end

    context "when the root taxonomy is not found" do
      let(:root_taxonomy_id) { 0 }

      it { is_expected.not_to be_valid }
    end

    context "when the taxonomy items are not found" do
      let(:taxonomy_items) { [0] }

      it { is_expected.not_to be_valid }
    end

    context "when the taxonomy items are not children of the root taxonomy" do
      let(:another_root_taxonomy) { create(:taxonomy, organization:) }
      let(:taxonomy_items) { [create(:taxonomy, parent: another_root_taxonomy, organization:).id] }

      it { is_expected.not_to be_valid }
    end

    describe "#from_model" do
      let(:taxonomy_filter) { create(:taxonomy_filter, name:, internal_name:, participatory_space_manifests:, root_taxonomy:) }
      let!(:filter_item) { create(:taxonomy_filter_item, taxonomy_item:, taxonomy_filter:) }
      let(:name) { { "en" => "Public name" } }
      let(:internal_name) { { "en" => "Internal Name" } }
      let(:participatory_space_manifests) { ["participatory_processes"] }

      subject { described_class.from_model(taxonomy_filter) }

      it "returns the form with the model attributes" do
        expect(subject.root_taxonomy_id).to eq(root_taxonomy.id)
        expect(subject.taxonomy_items).to eq([taxonomy_item.id])
        expect(subject.name).to eq(name)
        expect(subject.internal_name).to eq(internal_name)
        expect(subject.participatory_space_manifests).to eq(participatory_space_manifests)
      end

      context "when no name is present" do
        let(:name) { nil }
        let(:internal_name) { { "en" => "" } }

        it "returns an empty hash" do
          expect(subject.name).to eq({})
          expect(subject.internal_name).to eq({})
        end
      end
    end
  end
end
