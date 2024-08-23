# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe TaxonomyFilter do
    subject(:taxonomy_filter) { build(:taxonomy_filter, root_taxonomy:) }
    let(:root_taxonomy) { create(:taxonomy) }

    context "when everything is ok" do
      it { is_expected.to be_valid }
      it { is_expected.to respond_to(:root_taxonomy) }
      it { is_expected.to respond_to(:filter_items) }
    end

    context "when root taxonomy is missing" do
      before { taxonomy_filter.root_taxonomy = nil }

      it { is_expected.not_to be_valid }
    end

    context "when space manifest is missing" do
      before { taxonomy_filter.space_manifest = nil }

      it { is_expected.not_to be_valid }
    end

    context "when has associations" do
      subject(:taxonomy_filter) { create(:taxonomy_filter, :with_items) }

      it "has many filter items" do
        expect(taxonomy_filter.filter_items.count).to eq(3)
        expect(taxonomy_filter.filter_items_count).to eq(3)
      end
    end

    context "when root taxonomy is not a root taxonomy" do
      let(:taxonomy) { create(:taxonomy, parent: root_taxonomy) }

      subject(:taxonomy_filter) { build(:taxonomy_filter, root_taxonomy: taxonomy) }

      it { is_expected.not_to be_valid }
    end

    context "when space manifest is not registered" do
      subject(:taxonomy_filter) { build(:taxonomy_filter, space_manifest: "dummy_manifest") }

      it { is_expected.not_to be_valid }
    end

    context "when filtering taxonomies" do
      subject(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy:) }
      let(:organization) { root_taxonomy.organization }

      let!(:first_taxonomy) { create(:taxonomy, weight: 1, parent: root_taxonomy, organization:) }
      let!(:second_taxonomy) { create(:taxonomy, weight: 2, parent: root_taxonomy, organization:) }
      let!(:third_taxonomy) { create(:taxonomy, weight: 3, parent: root_taxonomy, organization:) }
      let!(:sub_taxonomy) { create(:taxonomy, parent: second_taxonomy, organization:) }
      let!(:sub_sub_taxonomy) { create(:taxonomy, parent: sub_taxonomy, organization:) }
      let!(:second_sub_taxonomy) { create(:taxonomy, parent: second_taxonomy, organization:) }

      let!(:filter_items) do
        [
          create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: third_taxonomy),
          create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: second_taxonomy),
          create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: first_taxonomy),
          create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: second_sub_taxonomy),
          create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: sub_taxonomy),
          create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: sub_sub_taxonomy)
        ]
      end

      let(:taxonomies_tree) do
        {
          first_taxonomy.id => {
            taxonomy: first_taxonomy,
            children: {}
          },
          second_taxonomy.id => {
            taxonomy: second_taxonomy,
            children: {
              sub_taxonomy.id => {
                taxonomy: sub_taxonomy,
                children: {
                  sub_sub_taxonomy.id => {
                    taxonomy: sub_sub_taxonomy,
                    children: {}
                  }
                }
              },
              second_sub_taxonomy.id => {
                taxonomy: second_sub_taxonomy,
                children: {}
              }
            }
          },
          third_taxonomy.id => {
            taxonomy: third_taxonomy,
            children: {}
          }
        }
      end

      it "returns a hash with the taxonomy tree structure" do
        expect(subject.taxonomies).to eq(taxonomies_tree)
      end

      context "when not all taxonomies are in the filters" do
        let!(:another_taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:) }
        let!(:another_sub_taxonomy) { create(:taxonomy, parent: second_taxonomy, organization:) }

        it "returns a hash with the taxonomy tree structure" do
          expect(subject.taxonomies).to eq(taxonomies_tree)
        end
      end
    end
  end
end
