# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/core/test"

module Decidim
  module Accountability
    describe AccountabilityType, type: :graphql do
      include_context "with a graphql class type"
      let(:model) { create(:accountability_component) }

      describe "" do
        subject { described_class }

        it_behaves_like "a component query type"
      end

      describe "results" do
        let!(:component_results) { create_list(:result, 2, component: model) }
        let!(:other_results) { create_list(:result, 2) }

        let(:query) { "{ results { edges { node { id } } } }" }

        it "returns the published results" do
          ids = response["results"]["edges"].map { |edge| edge["node"]["id"] }
          expect(ids).to include(*component_results.map(&:id).map(&:to_s))
          expect(ids).not_to include(*other_results.map(&:id).map(&:to_s))
        end
      end

      describe "result" do
        let(:query) { "query Result($id: ID!){ result(id: $id) { id } }" }
        let(:variables) { { id: result.id.to_s } }

        context "when the result belongs to the component" do
          let!(:result) { create(:result, component: model) }

          it "finds the result" do
            expect(response["result"]["id"]).to eq(result.id.to_s)
          end
        end

        context "when the result doesn't belong to the component" do
          let!(:result) { create(:result, component: create(:accountability_component)) }

          it "returns null" do
            expect(response["result"]).to be_nil
          end
        end
      end
    end
  end
end
