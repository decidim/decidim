# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Taxonomy do
    subject(:taxonomy) { build(:taxonomy, name: taxonomy_name, parent:, organization:) }

    let(:organization) { create(:organization) }
    let(:parent) { create(:taxonomy, organization:) }

    context "when everything ok" do
      let(:taxonomy_name) { { en: "Test Taxonomy" } }

      it "is valid with valid attributes" do
        expect(taxonomy).to be_valid
      end
    end

    context "when name is missing" do
      let(:taxonomy_name) { nil }

      it "is not valid without a name" do
        expect(taxonomy).not_to be_valid
      end
    end

    context "when organization is missing" do
      let(:taxonomy_name) { { en: "Test Taxonomy" } }

      it "is not valid without an organization" do
        taxonomy.organization = nil
        expect(taxonomy).not_to be_valid
      end
    end

    context "when managing associations" do
      let!(:child_taxonomy) { create(:taxonomy, parent: taxonomy, organization:) }
      let(:taxonomy_name) { { en: "Test Taxonomy" } }

      it "can belong to a parent taxonomy" do
        expect(taxonomy.parent).to eq(parent)
      end

      it "can have many children taxonomies" do
        expect(taxonomy.children).to include(child_taxonomy)
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
