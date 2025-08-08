# frozen_string_literal: true

require "spec_helper"

shared_examples_for "taxonomy settings" do
  describe "available_taxonomy_filters" do
    let(:organization) { create(:organization) }
    let(:participatory_space) { create(:participatory_process, organization:) }
    let!(:component) do
      create(:component,
             manifest_name: "dummy",
             participatory_space:,
             settings: {
               taxonomy_filters:
             })
    end
    let(:taxonomy_filters) { [] }

    it "is blank" do
      expect(subject.available_taxonomy_filters).to eq([])
    end

    context "when component does not respond to taxonomy_filters" do
      before do
        allow(subject.settings).to receive(:respond_to?).with(:taxonomy_filters).and_return(false)
      end

      it "is blank" do
        expect(subject.available_taxonomy_filters).to be_blank
        expect(subject.available_root_taxonomies).to be_blank
        expect(subject.available_taxonomy_ids).to eq([])
      end
    end

    context "when filters exist" do
      let(:root_taxonomy) { create(:taxonomy, organization:) }
      let(:taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:) }
      let(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy:) }
      let!(:taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: taxonomy) }
      let(:taxonomy_filters) { [taxonomy_filter.id, rand(1..100)] }

      it "returns the filters" do
        expect(subject.available_taxonomy_filters).to eq([taxonomy_filter])
        expect(subject.available_root_taxonomies).to eq([root_taxonomy])
        expect(subject.available_taxonomy_ids).to eq([taxonomy.id])
      end
    end
  end
end
