# frozen_string_literal: true

require "spec_helper"

module Decidim::Exporters
  describe OpenDataTaxonomySerializer do
    subject { described_class.new(resource) }

    let(:resource) { create(:taxonomy) }
    let(:serialized) { subject.serialize }

    describe "#serialize" do
      it "includes the id" do
        expect(serialized).to include(id: resource.id)
      end

      it "includes the name" do
        expect(serialized).to include(name: resource.name)
      end

      it "includes the parent_id" do
        expect(serialized).to include(parent_id: resource.parent_id)
      end

      it "includes the weight" do
        expect(serialized).to include(weight: resource.weight)
      end

      it "includes the children_count" do
        expect(serialized).to include(children_count: resource.children_count)
      end

      it "includes the taxonomizations_count" do
        expect(serialized).to include(taxonomizations_count: resource.taxonomizations_count)
      end

      it "includes the created_at" do
        expect(serialized).to include(created_at: resource.created_at)
      end

      it "includes the updated_at" do
        expect(serialized).to include(updated_at: resource.updated_at)
      end

      it "includes the filters_count" do
        expect(serialized).to include(filters_count: resource.filters_count)
      end

      it "includes the filter_items_count" do
        expect(serialized).to include(filter_items_count: resource.filter_items_count)
      end

      it "includes the part_of" do
        expect(serialized).to include(part_of: resource.part_of)
      end

      it "includes the is_root" do
        expect(serialized).to include(is_root: resource.root?)
      end
    end
  end
end
