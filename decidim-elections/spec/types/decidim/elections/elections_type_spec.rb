# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/core/test"

module Decidim
  module Elections
    describe ElectionsType, type: :graphql do
      include_context "with a graphql type"
      let(:model) { create(:elections_component) }

      it_behaves_like "a component query type"

      describe "elections" do
        let!(:component_elections) { create_list(:election, 2, component: model) }
        let!(:other_elections) { create_list(:election, 2) }

        let(:query) { "{ elections { edges { node { id } } } }" }

        it "returns the elections" do
          ids = response["elections"]["edges"].map { |edge| edge["node"]["id"] }
          expect(ids).to include(*component_elections.map(&:id).map(&:to_s))
          expect(ids).not_to include(*other_elections.map(&:id).map(&:to_s))
        end
      end

      describe "election" do
        let(:query) { "query Election($id: ID!){ election(id: $id) { id } }" }
        let(:variables) { { id: election.id.to_s } }

        context "when the election belongs to the component" do
          let!(:election) { create(:election, component: model) }

          it "finds the election" do
            expect(response["election"]["id"]).to eq(election.id.to_s)
          end
        end

        context "when the election doesn't belong to the component" do
          let!(:election) { create(:election) }

          it "returns null" do
            expect(response["election"]).to be_nil
          end
        end
      end
    end
  end
end
