# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe ProposalEndorsementsController, type: :controller do
      include_context "when in a proposal"

      #
      # As Organization
      #
      describe "As Organization" do
        let(:user_group) { create(:user_group, verified_at: DateTime.current) }

        before do
          create(:user_group_membership, user: user, user_group: user_group)
          params[:user_group_id] = user_group.id
        end

        describe "endorsing a Proposal" do
          context "when endorsements are enabled" do
            let(:feature) do
              create(:proposal_feature, :with_endorsements_enabled)
            end

            it "allows endorsing" do
              expect do
                post :create, format: :js, params: params
              end.to change(ProposalEndorsement, :count).by(1)

              expect(ProposalEndorsement.last.author).to eq(user)
              expect(ProposalEndorsement.last.proposal).to eq(proposal)
              expect(ProposalEndorsement.last.user_group).to eq(user_group)
            end
          end

          context "when endorsements are disabled" do
            let(:feature) do
              create(:proposal_feature, :with_endorsements_disabled)
            end

            it "does not allow endorsing" do
              expect do
                post :create, format: :js, params: params
              end.not_to change(ProposalEndorsement, :count)

              expect(flash[:alert]).not_to be_empty
              expect(response).to have_http_status(:found)
            end
          end

          context "when endorsements are enabled but endorsements are blocked" do
            let(:feature) do
              create(:proposal_feature, :with_endorsements_enabled, :with_endorsements_blocked)
            end

            it "does not allow endorsing" do
              expect do
                post :create, format: :js, params: params
              end.not_to change(ProposalEndorsement, :count)

              expect(flash[:alert]).not_to be_empty
              expect(response).to have_http_status(:found)
            end
          end
        end

        describe "As User unendorsing a Proposal" do
          before do
            create(:proposal_endorsement, proposal: proposal, author: user, user_group: user_group)
          end

          context "when endorsements are enabled" do
            let(:feature) do
              create(:proposal_feature, :with_endorsements_enabled)
            end

            it "deletes the endorsement" do
              expect do
                delete :destroy, format: :js, params: params
              end.to change(ProposalEndorsement, :count).by(-1)

              expect(ProposalEndorsement.count).to eq(0)
            end
          end

          context "when endorsements are disabled" do
            let(:feature) do
              create(:proposal_feature, :with_endorsements_disabled)
            end

            it "does not delete the endorsement" do
              expect do
                delete :destroy, format: :js, params: params
              end.not_to change(ProposalEndorsement, :count)

              expect(flash[:alert]).not_to be_empty
              expect(response).to have_http_status(:found)
            end
          end
        end
      end
    end
  end
end
