# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Proposals
    describe ProposalInputSort, type: :graphql do
      include_context "with a graphql class type"

      let(:type_class) { Decidim::Proposals::ProposalsType }

      let(:model) { create(:proposal_component) }
      let!(:models) { create_list(:proposal, 3, :published, component: model) }

      context "when sorting by proposals id" do
        include_examples "connection has input sort", "proposals", "id"
      end

      context "when sorting by published_at" do
        include_examples "connection has input sort", "proposals", "publishedAt"
      end

      context "when sorting by like_count" do
        let!(:most_liked) { create(:proposal, :published, :with_likes, component: model) }

        include_examples "connection has like_count sort", "proposals"
      end

      context "when sorting by vote_count" do
        let!(:votes) { create_list(:proposal_vote, 3, proposal: models.last) }

        describe "ASC" do
          let(:query) { %[{ proposals(order: {voteCount: "ASC"}) { edges { node { id } } } }] }

          it "returns the most voted last" do
            expect(response["proposals"]["edges"].count).to eq(3)
            expect(response["proposals"]["edges"].last["node"]["id"]).to eq(models.last.id.to_s)
          end
        end

        describe "DESC" do
          let(:query) { %[{ proposals(order: {voteCount: "DESC"}) { edges { node { id } } } }] }

          it "returns the most voted first" do
            expect(response["proposals"]["edges"].count).to eq(3)
            expect(response["proposals"]["edges"].first["node"]["id"]).to eq(models.last.id.to_s)
          end
        end
      end
    end
  end
end
