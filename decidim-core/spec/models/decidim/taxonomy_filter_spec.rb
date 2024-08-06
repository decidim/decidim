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

    context "when space manifes is not registered" do
      subject(:taxonomy_filter) { build(:taxonomy_filter, space_manifest: "dummy_manifest") }

      it { is_expected.not_to be_valid }
    end
  end
end
