# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/core/test"
require "decidim/core/test/shared_examples/has_publishable_input_sort"

module Decidim
  module Proposals
    describe ProposalInputSort, type: :graphql do
      include_context "with a graphql type"
      let(:type_class) { Decidim::Proposals::ProposalsType }

      let(:model) { create(:proposal_component) }

      # include_examples "has publishable input sort",

      describe "proposals sort by id" do
        let!(:proposals) { create_list(:proposal, 3, component: model) }
        # proposals(order: {endorsementCount: "desc"}, first: 2) {

        let(:query) { '{ proposals(order: {id: "ASC"}) { edges { node { id } } } }' }

        it "returns the published proposals ordered by id" do
          ids = response["proposals"]["edges"].map { |edge| edge["node"]["id"] }
          expect(ids).to eq(proposals.map(&:id).map(&:to_s))
        end
      end

      describe "proposals sort by id" do
        let!(:proposals) { create_list(:proposal, 2, component: model) }
        # proposals(order: {endorsementCount: "desc"}, first: 2) {

        let(:query) { '{ proposals(order: {id: "DESC"}) { edges { node { id } } } }' }

        it "returns the published proposals ordered by id" do
          ids = response["proposals"]["edges"].map { |edge| edge["node"]["id"] }
          expect(ids).to eq(proposals.map(&:id).reverse!.map(&:to_s))
        end
      end

      context "when searched by endorsement" do
        let!(:most_endorsed_proposal) { create(:proposal, component: model, created_at: 1.month.ago) }
        let!(:endorsements) { create_list(:proposal_endorsement, 3, proposal: most_endorsed_proposal) }
        let!(:less_endorsed_proposal) { create(:proposal, component: model) }

        describe "proposals sort by endorsementCount asc" do
          let(:query) { '{ proposals(order: {endorsementCount: "DESC"}) { edges { node { id } } } }' }

          it "returns the published proposals ordered by endorsementCount" do
            ids = response["proposals"]["edges"].map { |edge| edge["node"]["id"] }
            expect(ids).to eq([most_endorsed_proposal.id.to_s, less_endorsed_proposal.id.to_s])
          end
        end

        describe "proposals sort by endorsementCount desc" do
          let(:query) { '{ proposals(order: {endorsementCount: "ASC"}) { edges { node { id } } } }' }

          it "returns the published proposals ordered by endorsementCount" do
            ids = response["proposals"]["edges"].map { |edge| edge["node"]["id"] }
            expect(ids).to eq([less_endorsed_proposal.id.to_s, most_endorsed_proposal.id.to_s])
          end
        end
      end

      context "when searched by vote count" do
        let!(:most_voted_proposal) { create(:proposal, component: model, created_at: 1.month.ago) }
        let!(:votes) { create_list(:proposal_vote, 3, proposal: most_voted_proposal) }
        let!(:less_voted_proposal) { create(:proposal, component: model) }

        describe "proposals sort by vote count desc" do
          let(:query) { '{ proposals(order: {voteCount: "DESC"}) { edges { node { id } } } }' }

          it "returns the published proposals ordered by vote count desc" do
            ids = response["proposals"]["edges"].map { |edge| edge["node"]["id"] }
            expect(ids).to eq([most_voted_proposal.id.to_s, less_voted_proposal.id.to_s])
          end
        end

        describe "proposals sort by vote count asc" do
          let(:query) { '{ proposals(order: {voteCount: "ASC"}) { edges { node { id } } } }' }

          it "returns the published proposals ordered by endorsementCount asc" do
            ids = response["proposals"]["edges"].map { |edge| edge["node"]["id"] }
            expect(ids).to eq([less_voted_proposal.id.to_s, most_voted_proposal.id.to_s])
          end
        end
      end

      context "when searching by published at" do
        let!(:models) { create_list(:proposal, 3, :published, component: model) }

        include_examples "has publishable input sort in component", "ProposalInputSort", "proposals"
      end
    end
  end
end
