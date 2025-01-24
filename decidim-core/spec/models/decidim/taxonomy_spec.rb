# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Taxonomy do
    subject(:taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:) }

    let(:organization) { create(:organization) }
    let(:root_taxonomy) { create(:taxonomy, organization:) }

    context "when building" do
      subject(:taxonomy) { build(:taxonomy, name: taxonomy_name, parent: root_taxonomy, organization:) }
      let(:taxonomy_name) { attributes_for(:taxonomy)[:name] }

      context "when everything is ok" do
        it { is_expected.to be_valid }
        it { is_expected.not_to be_root }

        it "returns the root taxonomy" do
          expect(taxonomy.root_taxonomy).to eq(root_taxonomy)
        end
      end

      context "when name is missing" do
        let(:taxonomy_name) { nil }

        it { is_expected.to be_invalid }
      end
    end

    it { is_expected.to be_valid }
    it { is_expected.not_to be_root }
    it { is_expected.to be_versioned }

    it "returns the parent ids" do
      expect(taxonomy.root_taxonomy).to eq(root_taxonomy)
      expect(taxonomy.parent_ids).to eq([root_taxonomy.id])
    end

    describe "scopes" do
      let!(:taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:) }
      let!(:external_taxonomy) { create(:taxonomy, :with_parent) }

      it "returns the root taxonomies" do
        expect(described_class.roots).to include(root_taxonomy)
        expect(described_class.roots).to include(external_taxonomy.parent)
        expect(described_class.roots).not_to include(taxonomy)
        expect(described_class.roots).not_to include(external_taxonomy)
      end

      it "returns the non root taxonomies" do
        expect(described_class.non_roots).to include(taxonomy)
        expect(described_class.non_roots).to include(external_taxonomy)
        expect(described_class.non_roots).not_to include(root_taxonomy)
        expect(described_class.non_roots).not_to include(external_taxonomy.parent)
      end

      context "when filtering by organization" do
        let(:base) { described_class.for(organization) }

        it "returns the taxonomies for the organization" do
          expect(base).to include(taxonomy)
          expect(base).to include(root_taxonomy)
          expect(base).not_to include(external_taxonomy)
          expect(base).not_to include(external_taxonomy.parent)
        end

        it "returns the root taxonomies for the organization" do
          expect(base.roots).to include(root_taxonomy)
          expect(base.roots).not_to include(external_taxonomy.parent)
          expect(base.roots).not_to include(taxonomy)
          expect(base.roots).not_to include(external_taxonomy)
        end

        it "returns the non root taxonomies for the organization" do
          expect(base.non_roots).to include(taxonomy)
          expect(base.non_roots).not_to include(external_taxonomy)
          expect(base.non_roots).not_to include(root_taxonomy)
          expect(base.non_roots).not_to include(external_taxonomy.parent)
        end
      end
    end

    context "when root taxonomy" do
      subject(:taxonomy) { root_taxonomy }

      it { is_expected.to be_root }
    end

    context "when a child taxonomy" do
      subject(:child) { create(:taxonomy, parent: taxonomy, organization:) }

      it { is_expected.not_to be_root }

      it "returns the root taxonomy" do
        expect(child.root_taxonomy).to eq(root_taxonomy)
      end

      it "returns the parent ids" do
        expect(child.parent_ids).to contain_exactly(root_taxonomy.id, taxonomy.id)
      end
    end

    context "when organization is missing" do
      before { taxonomy.organization = nil }

      it { is_expected.to be_invalid }
    end

    describe "#weight" do
      let!(:taxonomy1) { create(:taxonomy, organization:) }
      let!(:taxonomy2) { create(:taxonomy, organization:) }

      it "sets a default weight" do
        expect(taxonomy1.weight).to eq(0)
        expect(taxonomy2.weight).to eq(1)
      end

      context "when different parents" do
        let!(:taxonomy1_child1) { create(:taxonomy, parent: taxonomy1, organization:) }
        let!(:taxonomy1_child2) { create(:taxonomy, parent: taxonomy1, organization:) }
        let!(:taxonomy2_child1) { create(:taxonomy, parent: taxonomy2, organization:) }
        let!(:taxonomy2_child2) { create(:taxonomy, parent: taxonomy2, organization:) }

        it "sets a default weight for children" do
          expect(taxonomy1_child1.weight).to eq(0)
          expect(taxonomy1_child2.weight).to eq(1)
          expect(taxonomy2_child1.weight).to eq(0)
          expect(taxonomy2_child2.weight).to eq(1)
        end
      end

      context "when weight is set" do
        subject(:taxonomy) { create(:taxonomy, weight: 5, organization:) }

        it "sets the specified weight" do
          expect(taxonomy.weight).to eq(5)
        end
      end
    end

    context "when managing associations" do
      context "with children" do
        let!(:child_taxonomy) { create(:taxonomy, parent: taxonomy, organization:) }

        it "can belong to a parent taxonomy" do
          expect(taxonomy.parent).to eq(root_taxonomy)
        end

        it "can have many children taxonomies" do
          expect(taxonomy.children).to include(child_taxonomy)
          expect(taxonomy.children.count).to eq(1)
        end

        it "can be deleted with children" do
          expect(root_taxonomy.children_count).to eq(1)
          expect { taxonomy.destroy }.to change(Decidim::Taxonomy, :count).by(-2)
          expect(Decidim::Taxonomy.find_by(id: taxonomy.id)).to be_nil
          expect(root_taxonomy.reload.children_count).to eq(0)
        end

        context "when more than 3 levels of children" do
          subject(:child_of_child_taxonomy) { build(:taxonomy, parent: grandchild_taxonomy, organization:) }

          let(:grandchild_taxonomy) { create(:taxonomy, parent: child_taxonomy, organization:) }

          it { is_expected.to be_invalid }
        end
      end

      context "with taxonomizations" do
        let!(:taxonomization) { create(:taxonomization, taxonomy:) }

        it "can be deleted if it has taxonomizations" do
          expect { taxonomy.destroy }.to change(Decidim::Taxonomy, :count).by(-1)
        end
      end

      context "with filters" do
        let!(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy:) }

        it "can be deleted if it has filters" do
          expect { root_taxonomy.destroy }.to change(Decidim::Taxonomy, :count).by(-1)
        end
      end

      context "when adding taxonomizations" do
        let(:taxonomization) { build(:taxonomization, taxonomy:) }

        it "can be associated with a taxonomization" do
          expect(taxonomy.taxonomizations_count).to eq(0)
          taxonomy.taxonomizations << taxonomization
          taxonomy.save
          expect(taxonomy.taxonomizations).to include(taxonomization)
          expect(taxonomy.taxonomizations_count).to eq(1)
        end
      end

      context "when adding taxonomizations to the root taxonomy" do
        let(:taxonomization) { build(:taxonomization, taxonomy: root_taxonomy) }

        it "cannot be associated with a taxonomization" do
          root_taxonomy.taxonomizations << taxonomization
          expect(root_taxonomy).to be_invalid
          expect(taxonomization).to be_invalid
        end
      end

      context "when adding taxonomy filters" do
        let(:taxonomy_filter) { build(:taxonomy_filter, root_taxonomy:) }

        it "can be associated with a taxonomy filter" do
          expect(root_taxonomy.filters_count).to eq(0)
          root_taxonomy.taxonomy_filters << taxonomy_filter
          root_taxonomy.save
          expect(root_taxonomy.taxonomy_filters).to include(taxonomy_filter)
          expect(root_taxonomy.filters_count).to eq(1)
        end
      end
    end

    context "when using ransackable taxonomies" do
      let(:taxonomy_attributes1) { attributes_for(:taxonomy) }
      let(:taxonomy_attributes2) { attributes_for(:taxonomy) }
      let(:taxonomy_name1) { taxonomy_attributes1[:name] }
      let(:taxonomy_name2) { taxonomy_attributes2[:name] }
      let!(:taxonomy1) { create(:taxonomy, :with_parent, name: taxonomy_name1, organization:) }
      let!(:sub_taxonomy1) { create(:taxonomy, parent: taxonomy1, organization:) }
      let!(:taxonomy2) { create(:taxonomy, :with_parent, name: taxonomy_name2, organization:) }

      it "returns taxonomies matching the name" do
        result = described_class.search_by_name(translated(taxonomy_attributes1[:name]))
        expect(result).to include(taxonomy1)
        expect(result).not_to include(taxonomy2)
        expect(result).not_to include(sub_taxonomy1)
      end

      it "returns taxonomies and sub taxonomies matching the part_of" do
        result = described_class.part_of(taxonomy1.id)
        expect(result).to include(taxonomy1)
        expect(result).to include(sub_taxonomy1)
        expect(result).not_to include(taxonomy2)
      end

      it "returns sub taxonomies matching the part_of" do
        result = described_class.part_of(sub_taxonomy1.id)
        expect(result).to include(sub_taxonomy1)
        expect(result).not_to include(taxonomy1)
        expect(result).not_to include(taxonomy2)
      end
    end

    describe "cycles validation" do
      subject(:taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:) }
      let(:sub_taxonomy) { create(:taxonomy, parent: taxonomy) }
      let(:sub_sub_taxonomy) { create(:taxonomy, parent: sub_taxonomy) }

      it "do not allows two taxonomies cycles" do
        taxonomy.parent = sub_taxonomy
        expect(subject).to be_invalid
      end

      it "do not allows three taxonomies cycles" do
        taxonomy.parent = sub_sub_taxonomy
        expect(subject).to be_invalid
      end
    end

    describe "part_of for top level taxonomies" do
      subject { build(:taxonomy, organization:) }

      it "is empty before save" do
        expect(subject.part_of).to be_empty
      end

      it "is updated after save" do
        subject.save
        expect(subject.part_of).to eq([subject.id])
      end

      context "with parent taxonomy" do
        subject { taxonomy }

        it "is updated after save" do
          subject.save
          expect(subject.part_of).to eq([subject.id, root_taxonomy.id])
        end
      end
    end

    describe "creating several taxonomies on a transaction" do
      let(:taxonomies) { create_list(:taxonomy, 8, organization:) }

      before do
        taxonomy.transaction do
          taxonomies.each_with_index do |tax, i|
            tax.update(parent_id: taxonomies[i / 2].id) if i.positive?
          end
        end
      end

      it "updates part_of lists" do
        {
          0 => [0],
          1 => [1, 0],
          2 => [2, 1, 0],
          3 => [3, 1, 0],
          4 => [4, 2, 1, 0]
        }.each do |s1, list|
          expect(taxonomies[s1].part_of).to eq(list.map { |i| taxonomies[i].id })
        end
      end
    end
  end
end
