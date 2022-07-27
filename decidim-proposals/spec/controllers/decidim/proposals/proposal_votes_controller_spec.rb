# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe ProposalVotesController, type: :controller do
      routes { Decidim::Proposals::Engine.routes }

      let(:proposal) { create(:proposal, component:) }
      let(:user) { create(:user, :confirmed, organization: component.organization) }

      let(:params) do
        {
          proposal_id: proposal.id,
          component_id: component.id
        }
      end

      before do
        request.env["decidim.current_organization"] = component.organization
        request.env["decidim.current_participatory_space"] = component.participatory_space
        request.env["decidim.current_component"] = component
        sign_in user
      end

      describe "POST create" do
        context "with votes enabled" do
          let(:component) do
            create(:proposal_component, :with_votes_enabled)
          end

          it "allows voting" do
            expect do
              post :create, format: :js, params:
            end.to change(ProposalVote, :count).by(1)

            expect(ProposalVote.last.author).to eq(user)
            expect(ProposalVote.last.proposal).to eq(proposal)
          end
        end

        context "with votes disabled" do
          let(:component) do
            create(:proposal_component)
          end

          it "doesn't allow voting" do
            expect do
              post :create, format: :js, params:
            end.not_to change(ProposalVote, :count)

            expect(flash[:alert]).not_to be_empty
            expect(response).to have_http_status(:found)
          end
        end

        context "with votes enabled but votes blocked" do
          let(:component) do
            create(:proposal_component, :with_votes_blocked)
          end

          it "doesn't allow voting" do
            expect do
              post :create, format: :js, params:
            end.not_to change(ProposalVote, :count)

            expect(flash[:alert]).not_to be_empty
            expect(response).to have_http_status(:found)
          end
        end
      end

      describe "destroy" do
        before do
          create(:proposal_vote, proposal:, author: user)
        end

        context "with vote limit enabled" do
          let(:component) do
            create(:proposal_component, :with_votes_enabled, :with_vote_limit)
          end

          it "deletes the vote" do
            expect do
              delete :destroy, format: :js, params:
            end.to change(ProposalVote, :count).by(-1)

            expect(ProposalVote.count).to eq(0)
          end
        end

        context "with vote limit disabled" do
          let(:component) do
            create(:proposal_component, :with_votes_enabled)
          end

          it "deletes the vote" do
            expect do
              delete :destroy, format: :js, params:
            end.to change(ProposalVote, :count).by(-1)

            expect(ProposalVote.count).to eq(0)
          end
        end
      end
    end
  end
end
