# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/core/test"

module Decidim
  module Sortitions
    describe SortitionsType, type: :graphql do
      include_context "with a graphql class type"
      let(:model) { create(:sortition_component) }

      it_behaves_like "a component query type"

      describe "sortitions" do
        let!(:component_sortitions) { create_list(:sortition, 2, component: model) }
        let!(:other_sortitions) { create_list(:sortition, 2) }

        let(:query) { "{ sortitions { edges { node { id } } } }" }

        it "returns the published sortitions" do
          ids = response["sortitions"]["edges"].map { |edge| edge["node"]["id"] }
          expect(ids).to include(*component_sortitions.map(&:id).map(&:to_s))
          expect(ids).not_to include(*other_sortitions.map(&:id).map(&:to_s))
        end
      end

      describe "sortition" do
        let(:query) { "query sortition($id: ID!){ sortition(id: $id) { id } }" }
        let(:variables) { { id: sortition.id.to_s } }

        context "when the sortition belongs to the component" do
          let!(:sortition) { create(:sortition, component: model) }

          it "finds the sortition" do
            expect(response["sortition"]["id"]).to eq(sortition.id.to_s)
          end
        end

        context "when the sortition doesn't belong to the component" do
          let!(:sortition) { create(:sortition, component: create(:sortition_component)) }

          it "returns null" do
            expect(response["sortition"]).to be_nil
          end
        end
      end
    end
  end
end
