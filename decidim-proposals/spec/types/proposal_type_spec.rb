# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/core/test/shared_examples/categorizable_interface_examples"
require "decidim/core/test/shared_examples/scopable_interface_examples"
require "decidim/core/test/shared_examples/attachable_interface_examples"
require "decidim/core/test/shared_examples/coauthorable_interface_examples"

module Decidim
  module Proposals
    describe ProposalType, type: :graphql do
      include_context "with a graphql type"
      let(:component) { create(:proposal_component) }
      let(:model) { create(:proposal, :with_votes, :with_endorsements, component: component) }

      include_examples "categorizable interface"
      include_examples "scopable interface"
      include_examples "attachable interface"
      include_examples "coauthorable interface"

      describe "id" do
        let(:query) { "{ id }" }

        it "returns the proposal's id" do
          expect(response["id"]).to eq(model.id.to_s)
        end
      end

      describe "voteCount" do
        let(:query) { "{ voteCount }" }

        context "when votes are not hidden" do
          it "returns the amount of votes for this proposal" do
            expect(response["voteCount"]).to eq(model.votes.count)
          end
        end

        context "when votes are hidden" do
          let(:component) { create(:proposal_component, :with_votes_hidden) }

          it "returns nil" do
            expect(response["voteCount"]).to eq(nil)
          end
        end
      end

      describe "endorsementsCount" do
        let(:query) { "{ endorsementsCount }" }

        it "returns the amount of endorsements for this proposal" do
          expect(response["endorsementsCount"]).to eq(model.endorsements.count)
        end
      end

      describe "endorsements" do
        let(:query) { "{ endorsements { name } }" }

        it "returns the endorsements this proposal has received" do
          endorsement_names = response["endorsements"].map { |endorsement| endorsement["name"] }
          expect(endorsement_names).to include(*model.endorsements.map(&:author).map(&:name))
        end
      end

      describe "body" do
        let(:query) { "{ body }" }

        it "returns the proposal's body" do
          expect(response["body"]).to eq(model.body)
        end
      end

      describe "state" do
        let(:query) { "{ state }" }

        it "returns the proposal's state" do
          expect(response["state"]).to eq(model.state)
        end
      end

      describe "publishedAt" do
        let(:query) { "{ publishedAt }" }

        it "returns when was this query published at" do
          expect(response["publishedAt"]).to eq(model.published_at.to_time.iso8601)
        end
      end

      describe "address" do
        let(:query) { "{ address }" }

        it "returns the address of this proposal" do
          expect(response["address"]).to eq(model.address)
        end
      end
    end
  end
end
