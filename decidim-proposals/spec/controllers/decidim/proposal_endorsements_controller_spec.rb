# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe ProposalEndorsementsController, type: :controller do
      routes { Decidim::Proposals::Engine.routes }

      let(:proposal) { create(:proposal, feature: feature) }
      let(:user) { create(:user, :confirmed, organization: feature.organization) }
      let(:params) do
        {
          proposal_id: proposal.id,
          feature_id: feature.id,
          participatory_process_slug: feature.participatory_space.slug
        }
      end

      before do
        request.env["decidim.current_organization"] = feature.organization
        request.env["decidim.current_feature"] = feature
        sign_in user
      end

      describe "As User" do
        context "when endorsements are enabled" do
          let(:feature) do
            create(:proposal_feature, :with_endorsements_enabled)
          end

          it "allows endorsements" do
            expect do
              post :create, format: :js, params: params
            end.to change { ProposalEndorsement.count }.by(1)

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
              ug = create(:user_group)
              ug.verified_at = DateTime.current if verified
              user.user_groups << ug
            end
            user.save!
          end
        end

        context "when endorsements are disabled" do
          let(:feature) do
            create(:proposal_feature, :with_endorsements_disabled)
          end

          it "does not allow endorsing" do
            expect do
              post :create, format: :js, params: params
            end.not_to change { ProposalEndorsement.count }

            expect(flash[:alert]).not_to be_empty
            expect(response).to have_http_status(302)
          end

          context "when requesting user identities" do
            it "raises exception" do
              get :identities, params: params
              expect(response).to have_http_status(302)
            end
          end
        end

        context "when endorsements are enabled but endorsements are blocked" do
          let(:feature) do
            create(:proposal_feature, :with_endorsements_enabled, :with_endorsements_blocked)
          end

          it "does not allow endorsing" do
            expect do
              post :create, format: :js, params: params
            end.not_to change { ProposalEndorsement.count }

            expect(flash[:alert]).not_to be_empty
            expect(response).to have_http_status(302)
          end

          context "when requesting user identities" do
            it "does not allow it" do
              get :identities, params: params
              expect(response).to have_http_status(302)
            end
          end
        end
      end

      describe "As User unendorsing a Proposal" do
        before do
          create(:proposal_endorsement, proposal: proposal, author: user)
        end

        context "when endorsements are enabled" do
          let(:feature) do
            create(:proposal_feature, :with_endorsements_enabled)
          end

          it "deletes the endorsement" do
            expect do
              delete :destroy, format: :js, params: params
            end.to change { ProposalEndorsement.count }.by(-1)

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
            end.not_to change { ProposalEndorsement.count }

            expect(flash[:alert]).not_to be_empty
            expect(response).to have_http_status(302)
          end
        end
      end

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
              end.to change { ProposalEndorsement.count }.by(1)

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
              end.not_to change { ProposalEndorsement.count }

              expect(flash[:alert]).not_to be_empty
              expect(response).to have_http_status(302)
            end
          end

          context "when endorsements are enabled but endorsements are blocked" do
            let(:feature) do
              create(:proposal_feature, :with_endorsements_enabled, :with_endorsements_blocked)
            end

            it "does not allow endorsing" do
              expect do
                post :create, format: :js, params: params
              end.not_to change { ProposalEndorsement.count }

              expect(flash[:alert]).not_to be_empty
              expect(response).to have_http_status(302)
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
              end.to change { ProposalEndorsement.count }.by(-1)

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
              end.not_to change { ProposalEndorsement.count }

              expect(flash[:alert]).not_to be_empty
              expect(response).to have_http_status(302)
            end
          end
        end
      end
    end
  end
end
