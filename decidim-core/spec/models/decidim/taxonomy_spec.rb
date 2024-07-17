# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Taxonomy do
    subject(:taxonomy) { build(:taxonomy, name: taxonomy_name, parent: root_taxonomy, organization:) }

    let(:organization) { create(:organization) }
    let(:root_taxonomy) { create(:taxonomy, organization:) }
    let(:taxonomy_name) { { en: "Test Taxonomy" } }

    context "when everything is ok" do
      it { is_expected.to be_valid }
      it { is_expected.not_to be_root }

      it "returns the root taxonomy" do
        expect(taxonomy.root_taxonomy).to eq(root_taxonomy)
      end

      it "returns the parent ids" do
        expect(taxonomy.parent_ids).to eq([root_taxonomy.id])
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
        expect(child.parent_ids).to eq([root_taxonomy.id, taxonomy.id])
      end
    end

    context "when name is missing" do
      let(:taxonomy_name) { nil }

      it { is_expected.to be_invalid }
    end

    context "when organization is missing" do
      before { taxonomy.organization = nil }

      it { is_expected.to be_invalid }
    end

    context "when managing associations" do
      context "with children" do
        let!(:child_taxonomy) { create(:taxonomy, parent: taxonomy, organization:) }

        it "can belong to a parent taxonomy" do
          expect(taxonomy.parent).to eq(root_taxonomy)
        end

        it "can have many children taxonomies" do
          expect(taxonomy.children).to include(child_taxonomy)
        end

        it "cannot be deleted if it has children" do
          expect { taxonomy.destroy }.not_to change(Decidim::Taxonomy, :count)
          expect(taxonomy.errors[:base]).to include("Cannot delete record because dependent children exist")
        end

        context "when more than two levels of children" do
          subject(:grandchild_taxonomy) { build(:taxonomy, parent: child_taxonomy, organization:) }

          it { is_expected.to be_invalid }
        end
      end

      context "with filters" do
        let!(:taxonomy_filter) { create(:taxonomy_filter, taxonomy:) }

        it "cannot be deleted if it has filters" do
          expect { taxonomy.destroy }.not_to change(Decidim::Taxonomy, :count)
          expect(taxonomy.errors[:base]).to include("Cannot delete record because dependent taxonomy filters exist")
        end
      end

      context "with taxonomizations" do
        let!(:taxonomization) { create(:taxonomization, taxonomy:) }

        it "cannot be deleted if it has taxonomizations" do
          expect { taxonomy.destroy }.not_to change(Decidim::Taxonomy, :count)
          expect(taxonomy.errors[:base]).to include("Cannot delete record because dependent taxonomizations exist")
        end
      end
    end

    context "when using ransackable scopes" do
      let(:taxonomy_name1) { { en: "Category1" } }
      let(:taxonomy_name2) { { en: "Category2" } }
      let!(:taxonomy1) { create(:taxonomy, name: taxonomy_name1, organization:) }
      let!(:taxonomy2) { create(:taxonomy, name: taxonomy_name2, organization:) }

      it "returns taxonomies matching the name" do
        result = described_class.search_by_name("Category1")
        expect(result).to include(taxonomy1)
        expect(result).not_to include(taxonomy2)
      end
    end
  end
end
