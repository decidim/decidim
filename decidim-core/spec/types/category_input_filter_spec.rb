# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/core/test"

module Decidim
  module Core
    describe CategoryInputFilter, type: :graphql do
      include_context "with a graphql class type"
      let(:type_class) { Decidim::ParticipatoryProcesses::ParticipatoryProcessType }

      let(:model) { create(:participatory_process, organization: current_organization) }
      let!(:category1) { create(:category, participatory_space: model) }
      let!(:category2) { create(:category, participatory_space: model) }
      let!(:category1_sub) { create_list(:subcategory, 3, parent: category1) }
      let!(:category2_sub) { create_list(:subcategory, 3, parent: category2) }
      let(:all_ids) do
        [
          [category1.id, category2.id],
          category1_sub.map(&:id),
          category2_sub.map(&:id)
        ].flatten
      end

      context "when no filters are applied" do
        let(:query) { %[{ categories(filter: {}) { id } }] }

        it "returns all the types" do
          ids = response["categories"].map { |cat| cat["id"].to_i }
          expect(ids).to include(*all_ids)
        end
      end

      context "when filtering by parent ID" do
        let(:query) { %[{ categories(filter: { parentId: #{category1.id} }) { id } }] }

        it "returns the types requested" do
          ids = response["categories"].map { |cat| cat["id"].to_i }
          expect(ids).to include(*category1_sub.map(&:id))
          expect(ids).not_to include(*category2_sub.map(&:id))
          expect(ids).not_to include(category1.id, category2.id)
        end
      end

      context "when filtering by top level categories" do
        let(:query) { %[{ categories(filter: { parentId: null }) { id } }] }

        it "returns the types requested" do
          ids = response["categories"].map { |cat| cat["id"].to_i }
          expect(ids).to include(category1.id, category2.id)
          expect(ids).not_to include(*category1_sub.map(&:id))
          expect(ids).not_to include(*category2_sub.map(&:id))
        end
      end

      context "when parent ID is not present" do
        let(:unexisting_id) { all_ids.last + 1 }
        let(:query) { %[{ categories(filter: { parentId: #{unexisting_id} }) { id } }] }

        it "returns an empty array" do
          expect(response["categories"]).to eq([])
        end
      end
    end
  end
end
