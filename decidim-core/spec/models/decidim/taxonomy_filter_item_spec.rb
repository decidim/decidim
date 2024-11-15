# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe TaxonomyFilterItem do
    subject(:taxonomy_filter_item) { build(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item:) }
    let(:root_taxonomy) { create(:taxonomy) }
    let(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy:) }
    let(:taxonomy_item) { create(:taxonomy, parent: root_taxonomy) }

    context "when everything is ok" do
      it { is_expected.to be_valid }
    end

    context "when taxonomy filter is missing" do
      before { taxonomy_filter_item.taxonomy_filter = nil }

      it { is_expected.not_to be_valid }
    end

    context "when taxonomy item is missing" do
      before { taxonomy_filter_item.taxonomy_item = nil }

      it { is_expected.not_to be_valid }
    end

    context "when taxonomy_item is a root taxonomy" do
      let(:taxonomy_item) { build(:taxonomy) }

      it { is_expected.to be_invalid }
    end

    context "when taxonomy_item is not a children of the taxonomy_filter taxonomy root" do
      let(:taxonomy_item) { build(:taxonomy, :with_parent) }

      it { is_expected.to be_invalid }
    end
  end
end
