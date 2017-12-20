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
            it "onlies return the user identity endorse button" do
              get :identities, params: params

              expect(response).to have_http_status(:ok)
              expect(assigns[:to_endorse_groups]).to be_empty
              expect(assigns[:to_unendorse_groups]).to be_empty
            end
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

      #
      # Identity endorsements combinations
      #
      describe "When user has some of its user_groups endorsed" do
        let(:feature) do
          create(:proposal_feature, :with_endorsements_enabled)
        end
        let(:endorsed_groups) { [] }
        let(:unendorsed_groups) { [] }

        context "when user has no user_groups" do
          it "returns only an endorse button for the user" do
            get :identities, params: params

            expect(response).to have_http_status(:ok)
            expect(subject).to render_template("decidim/proposals/proposal_endorsements/identities")
          end
        end
        context "when all user user_groups are endorsed" do
          it "offers user_groups to unahere" do
            create_endorsed_groups

            get :identities, params: params

            expect(response).to have_http_status(:ok)
            expect(assigns[:to_endorse_groups]).to be_empty
            expect(assigns[:to_unendorse_groups]).to eq(endorsed_groups)
            expect(subject).to render_template("decidim/proposals/proposal_endorsements/identities")
          end
        end
        context "when half user organizations are endorsed" do
          it "offers the corresponding action to each organization" do
            create_endorsed_groups
            create_unendorsed_groups

            get :identities, params: params

            expect(response).to have_http_status(:ok)
            expect(assigns[:to_endorse_groups]).to eq(unendorsed_groups)
            expect(assigns[:to_unendorse_groups]).to eq(endorsed_groups)
            expect(subject).to render_template("decidim/proposals/proposal_endorsements/identities")
          end
        end
        context "when none of user's user_groups are endorsed" do
          it "offers all user_groups to endorse" do
            create_unendorsed_groups

            get :identities, params: params

            expect(response).to have_http_status(:ok)
            expect(assigns[:to_endorse_groups]).to eq(unendorsed_groups)
            expect(assigns[:to_unendorse_groups]).to be_empty
            expect(subject).to render_template("decidim/proposals/proposal_endorsements/identities")
          end
        end
      end

      #
      # ÚTIL METHODS
      #
      def create_endorsed_groups
        2.times do
          endorsement = create(:organization_proposal_endorsement,
                               proposal: proposal, author: user)
          ug = endorsement.user_group
          ug.verified_at = DateTime.current
          endorsed_groups << ug.id
        end
        user.save!
      end

      def create_unendorsed_groups
        2.times do
          ug = create(:user_group, verified_at: DateTime.current)
          user.user_groups << ug
          unendorsed_groups << ug.id
        end
        user.save!
      end
    end
  end
end
