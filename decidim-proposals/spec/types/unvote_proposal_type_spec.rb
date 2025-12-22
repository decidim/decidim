# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/mutation_context"

module Decidim
  module Proposals
    describe UnvoteProposalType, type: :graphql do
      include_context "with a graphql class mutation"

      let(:root_klass) { ProposalMutationType }
      let(:current_organization) { create(:organization, available_locales: [:en]) }
      let(:participatory_process) { create(:participatory_process, :with_steps, organization: current_organization) }
      let(:proposal_component) do
        create(:proposal_component,
               :with_votes_enabled,
               participatory_space: participatory_process)
      end
      let!(:model) { create(:proposal, component: proposal_component) }
      let(:component) { model.component }
      let(:query) do
        <<~GRAPHQL
          mutation {
            unvote(input: {}) {
              id
              voteCount
            }
          }
        GRAPHQL
      end
      let(:variables) do
        {
          input: {
            attributes: {}
          }
        }
      end

      context "with a normal user" do
        let(:user_type) { :user }

        context "when the user has voted" do
          before do
            create(:proposal_vote, proposal: model, author: current_user)
          end

          it "removes the vote from the proposal" do
            expect do
              expect(response["unvote"]).not_to be_nil
            end.to change(ProposalVote, :count).by(-1)
          end

          it "returns the proposal with updated vote count" do
            unvote = response["unvote"]
            expect(unvote).to be_present
            expect(unvote["id"]).to eq(model.id.to_s)
            expect(unvote["voteCount"]).to eq(0)
          end
        end

        context "when the user has not voted" do
          it "does not change vote count" do
            expect do
              response
            end.not_to change(ProposalVote, :count)
          end

          it "returns the proposal" do
            unvote = response["unvote"]
            expect(unvote).to be_present
            expect(unvote["id"]).to eq(model.id.to_s)
            expect(unvote["voteCount"]).to eq(0)
          end
        end

        context "when votes are disabled" do
          let(:proposal_component) do
            create(:proposal_component,
                   :with_votes_disabled,
                   participatory_space: participatory_process)
          end

          before do
            create(:proposal_vote, proposal: model, author: current_user)
          end

          it "raises a Decidim::Api::Errors::MutationNotAuthorizedError exception" do
            expect { response }.to raise_error(Decidim::Api::Errors::MutationNotAuthorizedError, "You do not have permission to perform this mutation")
          end
        end
      end

      context "with an unauthenticated user" do
        let(:current_user) { nil }

        it "raises a Decidim::Api::Errors::MutationNotAuthorizedError exception" do
          expect { response }.to raise_error(Decidim::Api::Errors::MutationNotAuthorizedError, "You do not have permission to perform this mutation")
        end
      end
    end
  end
end
