# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe TaxonomyFilter do
    subject(:taxonomy_filter) { build(:taxonomy_filter, root_taxonomy:) }
    let(:root_taxonomy) { create(:taxonomy) }

    context "when everything is ok" do
      it { is_expected.to be_valid }
      it { is_expected.to be_versioned }
      it { is_expected.to respond_to(:root_taxonomy) }
      it { is_expected.to respond_to(:filter_items) }

      it "has the same name as the root taxonomy" do
        expect(taxonomy_filter.name).to eq(root_taxonomy.name)
        expect(taxonomy_filter.internal_name).to eq(root_taxonomy.name)
      end

      describe "scopes" do
        let!(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy:, participatory_space_manifests: [:assemblies, :participatory_processes]) }
        let!(:external_taxonomy_filter) { create(:taxonomy_filter, participatory_space_manifests: [:assemblies]) }

        it "returns only the organization taxonomy filters" do
          expect(Decidim::TaxonomyFilter.for(root_taxonomy.organization).count).to eq(1)
          expect(Decidim::TaxonomyFilter.for(root_taxonomy.organization).first).to eq(taxonomy_filter)
        end

        it "returns the filters for space manifests" do
          expect(Decidim::TaxonomyFilter.for_manifest("assemblies").count).to eq(2)
          expect(Decidim::TaxonomyFilter.for_manifest("assemblies").all).to include(taxonomy_filter, external_taxonomy_filter)
          expect(Decidim::TaxonomyFilter.for(root_taxonomy.organization).for_manifest("assemblies").count).to eq(1)
          expect(Decidim::TaxonomyFilter.for(root_taxonomy.organization).for_manifest("assemblies").first).to eq(taxonomy_filter)
        end
      end
    end

    context "when the filter taxonomy has a custom name" do
      subject(:taxonomy_filter) { build(:taxonomy_filter, root_taxonomy:, name: { en: "Custom name" }) }

      it "has the custom name" do
        expect(taxonomy_filter.name["en"]).to eq("Custom name")
        expect(taxonomy_filter.internal_name).to eq(root_taxonomy.name)
      end
    end

    context "when the filter taxonomy has empty strings" do
      subject(:taxonomy_filter) { build(:taxonomy_filter, root_taxonomy:, name: { en: "" }, internal_name: { en: "" }) }

      it "has the same name as the root taxonomy" do
        expect(taxonomy_filter.name).to eq(root_taxonomy.name)
        expect(taxonomy_filter.internal_name).to eq(root_taxonomy.name)
      end
    end

    context "when the filter taxonomy has a custom internal name" do
      subject(:taxonomy_filter) { build(:taxonomy_filter, root_taxonomy:, internal_name: { en: "Custom internal name" }) }

      it "has the custom internal name" do
        expect(taxonomy_filter.internal_name["en"]).to eq("Custom internal name")
        expect(taxonomy_filter.name).to eq(root_taxonomy.name)
      end
    end

    context "when root taxonomy is missing" do
      before { taxonomy_filter.root_taxonomy = nil }

      it { is_expected.not_to be_valid }
    end

    context "when participatory space manifests are missing" do
      before { taxonomy_filter.participatory_space_manifests = [] }

      it { is_expected.to be_valid }
    end

    context "when has associations" do
      subject(:taxonomy_filter) { create(:taxonomy_filter, :with_items) }

      it "has many filter items" do
        expect(taxonomy_filter.filter_items.count).to eq(3)
        expect(taxonomy_filter.filter_items_count).to eq(3)
      end
    end

    context "when has components" do
      let(:participatory_space) { create(:participatory_process, organization: root_taxonomy.organization) }
      let!(:component1) { create(:component, settings: { taxonomy_filters: ids1 }) }
      let!(:component2) { create(:component, participatory_space:, settings: { taxonomy_filters: ids2 }) }
      let(:taxonomy_filter1) { create(:taxonomy_filter, root_taxonomy:, participatory_space_manifests: [participatory_space.manifest.name]) }
      let(:taxonomy_filter2) { create(:taxonomy_filter, root_taxonomy:, participatory_space_manifests: [participatory_space.manifest.name]) }
      let(:ids1) { [taxonomy_filter1.id.to_s] }
      let(:ids2) { [taxonomy_filter1.id.to_s, taxonomy_filter2.id.to_s] }

      it "has many components" do
        expect(taxonomy_filter1.components).to contain_exactly(component1, component2)
        expect(taxonomy_filter2.components).to contain_exactly(component2)
        expect(taxonomy_filter1.reload.components_count).to eq(2)
        expect(taxonomy_filter2.reload.components_count).to eq(1)
      end
    end

    context "when root taxonomy is not a root taxonomy" do
      let(:taxonomy) { create(:taxonomy, parent: root_taxonomy) }

      subject(:taxonomy_filter) { build(:taxonomy_filter, root_taxonomy: taxonomy) }

      it { is_expected.not_to be_valid }
    end

    context "when space manifest is not registered" do
      subject(:taxonomy_filter) { build(:taxonomy_filter, participatory_space_manifests: ["dummy_manifest"]) }

      it { is_expected.not_to be_valid }
    end

    context "when filtering taxonomies" do
      subject(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy:) }
      let(:organization) { root_taxonomy.organization }

      let!(:second_taxonomy) { create(:taxonomy, weight: 2, parent: root_taxonomy, organization:) }
      let!(:first_taxonomy) { create(:taxonomy, weight: 1, parent: root_taxonomy, organization:) }
      let!(:third_taxonomy) { create(:taxonomy, weight: 3, parent: root_taxonomy, organization:) }
      let!(:sub_taxonomy) { create(:taxonomy, parent: second_taxonomy, organization:) }
      let!(:second_sub_taxonomy) { create(:taxonomy, parent: second_taxonomy, organization:) }
      let!(:sub_sub_taxonomy) { create(:taxonomy, parent: sub_taxonomy, organization:) }

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
