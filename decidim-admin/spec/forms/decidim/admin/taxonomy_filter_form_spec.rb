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
            OpenStruct.new(
              name: translated(taxonomy_child.name),
              value: taxonomy_child.id,
              children: [
                OpenStruct.new(
                  name: translated(taxonomy_grandchild.name),
                  value: taxonomy_grandchild.id,
                  children: [
                    OpenStruct.new(
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

      it "returns all the filter items" do
        expect(subject.filter_items).to contain_exactly(taxonomy_child, taxonomy_grandchild, taxonomy_item)
      end
    end
  end
end
