# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Proposals
    describe ProposalVotesController, type: :controller do
      let(:proposal) { create(:proposal, feature: feature) }
      let(:user) { create(:user, :confirmed, organization: feature.organization) }

      routes do
        Decidim::Proposals::Engine.routes
      end

      before do
        @request.env["decidim.current_organization"] = feature.organization
        @request.env["decidim.current_participatory_process"] = feature.participatory_process
        @request.env["decidim.current_feature"] = feature
        sign_in user
      end

      let(:params) do
        {
          proposal_id: proposal.id,
          feature_id: feature.id,
          participatory_process_id: feature.participatory_process.id
        }
      end

      describe "POST create" do
        context "with votes enabled" do
          let(:feature) do
            create(:proposal_feature, :with_votes_enabled)
          end

          it "allows voting" do
            expect do
              post :create, format: :js, params: params
            end.to change { ProposalVote.count }.by(1)

            expect(ProposalVote.last.author).to eq(user)
            expect(ProposalVote.last.proposal).to eq(proposal)
          end
        end

        context "with votes disabled" do
          let(:feature) do
            create(:proposal_feature)
          end

          it "doesn't allow voting" do
            expect do
              post :create, format: :js, params: params
            end.not_to change { ProposalVote.count }

            expect(response).to have_http_status(422)
          end
        end

        context "with votes enabled but votes blocked" do
          let(:feature) do
            create(:proposal_feature, :with_votes_blocked)
          end

          it "doesn't allow voting" do
            expect do
              post :create, format: :js, params: params
            end.not_to change { ProposalVote.count }

            expect(response).to have_http_status(422)
          end
        end
      end

      describe "destroy" do
        before do
          create(:proposal_vote, proposal: proposal, author: user)
        end

        context "with vote limit enabled" do
          let(:feature) do
            create(:proposal_feature, :with_votes_enabled, :with_vote_limit)
          end

          it "deletes the vote" do
            expect do
              delete :destroy, format: :js, params: params
            end.to change { ProposalVote.count }.by(-1)

            expect(ProposalVote.count).to eq(0)
          end
        end

        context "with vote limit disabled" do
          let(:feature) do
            create(:proposal_feature, :with_votes_enabled)
          end

          it "does not allow deleting a vote" do
            expect do
              delete :destroy, format: :js, params: params
            end.not_to change { ProposalVote.count }

            expect(response).to have_http_status(422)
            expect(ProposalVote.count).to eq(1)
          end
        end
      end
    end
  end
end
