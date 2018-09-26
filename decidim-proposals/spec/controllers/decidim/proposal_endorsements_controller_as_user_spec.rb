# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe ProposalEndorsementsController, type: :controller do
      include_context "when in a proposal"

      describe "As User" do
        context "when endorsements are enabled" do
          let(:component) do
            create(:proposal_component, :with_endorsements_enabled)
          end

          it "allows endorsements" do
            expect do
              post :create, format: :js, params: params
            end.to change(ProposalEndorsement, :count).by(1)

            expect(ProposalEndorsement.last.author).to eq(user)
            expect(ProposalEndorsement.last.proposal).to eq(proposal)
          end

          context "when requesting user identities without belonging to any user_group" do
            it "only returns the user identity endorse button" do
              get :identities, params: params

              expect(response).to have_http_status(:ok)
              expect(assigns[:user_verified_groups]).to be_empty
              expect(subject).to render_template("decidim/proposals/proposal_endorsements/identities")
            end
          end

          context "when requesting user identities while belonging to UNverified user_groups" do
            it "only returns the user identity endorse button" do
              create_user_groups
              get :identities, params: params

              expect(response).to have_http_status(:ok)
              expect(assigns[:user_verified_groups]).to be_empty
              expect(subject).to render_template("decidim/proposals/proposal_endorsements/identities")
            end
          end

          context "when requesting user identities while belonging to verified user_groups" do
            it "returns the user's and user_groups's identities for the endorse button" do
              create_user_groups(true)
              get :identities, params: params

              expect(response).to have_http_status(:ok)
              expect(assigns[:user_verified_groups]).to eq user.user_groups
              expect(subject).to render_template("decidim/proposals/proposal_endorsements/identities")
            end
          end
          #
          # UTIL METHODS
          #

          def create_user_groups(verified = false)
            2.times do
              user_group = create(:user_group)
              user_group.verified_at = Time.current if verified
              user.user_groups << user_group
            end
            user.save!
          end
        end

        context "when endorsements are disabled" do
          let(:component) do
            create(:proposal_component, :with_endorsements_disabled)
          end

          it "does not allow endorsing" do
            expect do
              post :create, format: :js, params: params
            end.not_to change(ProposalEndorsement, :count)

            expect(flash[:alert]).not_to be_empty
            expect(response).to have_http_status(:found)
          end

          context "when requesting user identities" do
            it "raises exception" do
              get :identities, params: params
              expect(response).to have_http_status(:found)
            end
          end
        end

        context "when endorsements are enabled but endorsements are blocked" do
          let(:component) do
            create(:proposal_component, :with_endorsements_enabled, :with_endorsements_blocked)
          end

          it "does not allow endorsing" do
            expect do
              post :create, format: :js, params: params
            end.not_to change(ProposalEndorsement, :count)

            expect(flash[:alert]).not_to be_empty
            expect(response).to have_http_status(:found)
          end

          context "when requesting user identities" do
            it "does not allow it" do
              get :identities, params: params
              expect(response).to have_http_status(:found)
            end
          end
        end
      end

      describe "As User unendorsing a Proposal" do
        before do
          create(:proposal_endorsement, proposal: proposal, author: user)
        end

        context "when endorsements are enabled" do
          let(:component) do
            create(:proposal_component, :with_endorsements_enabled)
          end

          it "deletes the endorsement" do
            expect do
              delete :destroy, format: :js, params: params
            end.to change(ProposalEndorsement, :count).by(-1)

            expect(ProposalEndorsement.count).to eq(0)
          end
        end

        context "when endorsements are disabled" do
          let(:component) do
            create(:proposal_component, :with_endorsements_disabled)
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
