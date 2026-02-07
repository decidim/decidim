# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe VoteProposalType, type: :graphql do
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
            vote(input: {}) {
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

        context "when votes are enabled" do
          it "votes the proposal" do
            expect do
              expect(response["vote"]).not_to be_nil
            end.to change(ProposalVote, :count).by(1)
          end

          it "returns the proposal with updated vote count" do
            vote = response["vote"]
            expect(vote).to be_present
            expect(vote["id"]).to eq(model.id.to_s)
            expect(vote["voteCount"]).to eq(1)
          end
        end

        context "when the user has already voted" do
          before do
            create(:proposal_vote, proposal: model, author: current_user)
          end

          it "raises a Decidim::Api::Errors::ValidationError exception" do
            expect { response }.to raise_error(Decidim::Api::Errors::ValidationError, "There was a problem voting the proposal.")
          end
        end

        context "when votes are disabled" do
          let(:proposal_component) do
            create(:proposal_component,
                   :with_votes_disabled,
                   participatory_space: participatory_process)
          end

          it "raises a Decidim::Api::Errors::MutationNotAuthorizedError exception" do
            expect { response }.to raise_error(Decidim::Api::Errors::MutationNotAuthorizedError, "You do not have permission to perform this mutation")
          end
        end

        context "when the proposal has reached maximum votes" do
          before do
            allow(model).to receive(:maximum_votes_reached?).and_return(true)
            allow(model).to receive(:can_accumulate_votes_beyond_threshold).and_return(false)
          end

          it "raises a Decidim::Api::Errors::ValidationError exception" do
            expect { response }.to raise_error(Decidim::Api::Errors::ValidationError, "There was a problem voting the proposal.")
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
