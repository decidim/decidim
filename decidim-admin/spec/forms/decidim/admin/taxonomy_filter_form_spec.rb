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
    let(:participatory_space_manifest) { :participatory_processes }
    let(:context) do
      {
        current_organization: organization,
        participatory_space_manifest:
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

      it "returns all parent filter items" do
        expect(subject.filter_items.map(&:taxonomy_item_id)).to contain_exactly(taxonomy_child.id, taxonomy_grandchild.id, taxonomy_item.id)
      end

      context "when grandchild is selected" do
        let(:taxonomy_items) { [taxonomy_grandchild.id] }

        it { is_expected.to be_valid }

        it "returns all parent filter items" do
          expect(subject.filter_items.map(&:taxonomy_item_id)).to contain_exactly(taxonomy_child.id, taxonomy_grandchild.id)
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
  end
end
