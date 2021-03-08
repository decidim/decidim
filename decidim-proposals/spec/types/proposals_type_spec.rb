# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/core/test"

module Decidim
  module Proposals
    describe ProposalsType, type: :graphql do
      include_context "with a graphql class type"
      let(:model) { create(:proposal_component) }

      it_behaves_like "a component query type"

      describe "proposals" do
        let!(:draft_proposals) { create_list(:proposal, 2, :draft, component: model) }
        let!(:published_proposals) { create_list(:proposal, 2, component: model) }
        let!(:other_proposals) { create_list(:proposal, 2) }

        let(:query) { "{ proposals { edges { node { id } } } }" }

        it "returns the published proposals" do
          ids = response["proposals"]["edges"].map { |edge| edge["node"]["id"] }
          # We expect the default order to be ascending by ID, so the array
          # needs to match exactly the ordered IDs array.
          expect(ids).to eq(published_proposals.map(&:id).sort.map(&:to_s))
          expect(ids).not_to include(*draft_proposals.map(&:id).map(&:to_s))
          expect(ids).not_to include(*other_proposals.map(&:id).map(&:to_s))
        end
      end

      describe "proposal" do
        let(:query) { "query Proposal($id: ID!){ proposal(id: $id) { id } }" }
        let(:variables) { { id: proposal.id.to_s } }

        context "when the proposal belongs to the component" do
          let!(:proposal) { create(:proposal, component: model) }

          it "finds the proposal" do
            expect(response["proposal"]["id"]).to eq(proposal.id.to_s)
          end
        end

        context "when the proposal doesn't belong to the component" do
          let!(:proposal) { create(:proposal, component: create(:proposal_component)) }

          it "returns null" do
            expect(response["proposal"]).to be_nil
          end
        end

        context "when the proposal is not published" do
          let!(:proposal) { create(:proposal, :draft, component: model) }

          it "returns null" do
            expect(response["proposal"]).to be_nil
          end
        end
      end
    end
  end
end
