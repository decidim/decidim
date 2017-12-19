# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe ProposalAdhesionsController, type: :controller do
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
        context "when adhesions are enabled" do
          let(:feature) do
            create(:proposal_feature, :with_adhesions_enabled)
          end

          it "allows adheering" do
            expect do
              post :create, format: :js, params: params
            end.to change { ProposalAdhesion.count }.by(1)

            expect(ProposalAdhesion.last.author).to eq(user)
            expect(ProposalAdhesion.last.proposal).to eq(proposal)
          end

          context "when requesting user identities without belonging to any user_group" do
            it "onlies return the user identity adhere button" do
              get :identities, params: params

              expect(response).to have_http_status(:ok)
              expect(assigns[:to_adhere_groups]).to be_empty
              expect(assigns[:to_unadhere_groups]).to be_empty
            end
          end
        end

        context "when adhesions are disabled" do
          let(:feature) do
            create(:proposal_feature, :with_adhesions_disabled)
          end

          it "does not allow adheering" do
            expect do
              post :create, format: :js, params: params
            end.not_to change { ProposalAdhesion.count }

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

        context "when adhesions are enabled but adhesions are blocked" do
          let(:feature) do
            create(:proposal_feature, :with_adhesions_enabled, :with_adhesions_blocked)
          end

          it "does not allow adheering" do
            expect do
              post :create, format: :js, params: params
            end.not_to change { ProposalAdhesion.count }

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
      describe "As User unadheering a Proposal" do
        before do
          create(:proposal_adhesion, proposal: proposal, author: user)
        end
        context "when adhesions are enabled" do
          let(:feature) do
            create(:proposal_feature, :with_adhesions_enabled)
          end

          it "deletes the adhesion" do
            expect do
              delete :destroy, format: :js, params: params
            end.to change { ProposalAdhesion.count }.by(-1)

            expect(ProposalAdhesion.count).to eq(0)
          end
        end
        context "when adhesions are disabled" do
          let(:feature) do
            create(:proposal_feature, :with_adhesions_disabled)
          end

          it "does not delete the adhesion" do
            expect do
              delete :destroy, format: :js, params: params
            end.not_to change { ProposalAdhesion.count }

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
        describe "adheering a Proposal" do
          context "when adhesions are enabled" do
            let(:feature) do
              create(:proposal_feature, :with_adhesions_enabled)
            end

            it "allows adheering" do
              expect do
                post :create, format: :js, params: params
              end.to change { ProposalAdhesion.count }.by(1)

              expect(ProposalAdhesion.last.author).to eq(user)
              expect(ProposalAdhesion.last.proposal).to eq(proposal)
              expect(ProposalAdhesion.last.user_group).to eq(user_group)
            end
          end

          context "when adhesions are disabled" do
            let(:feature) do
              create(:proposal_feature, :with_adhesions_disabled)
            end

            it "does not allow adheering" do
              expect do
                post :create, format: :js, params: params
              end.not_to change { ProposalAdhesion.count }

              expect(flash[:alert]).not_to be_empty
              expect(response).to have_http_status(302)
            end
          end

          context "when adhesions are enabled but adhesions are blocked" do
            let(:feature) do
              create(:proposal_feature, :with_adhesions_enabled, :with_adhesions_blocked)
            end

            it "does not allow adheering" do
              expect do
                post :create, format: :js, params: params
              end.not_to change { ProposalAdhesion.count }

              expect(flash[:alert]).not_to be_empty
              expect(response).to have_http_status(302)
            end
          end
        end
        describe "As User unadheering a Proposal" do
          before do
            create(:proposal_adhesion, proposal: proposal, author: user, user_group: user_group)
          end
          context "when adhesions are enabled" do
            let(:feature) do
              create(:proposal_feature, :with_adhesions_enabled)
            end

            it "deletes the adhesion" do
              expect do
                delete :destroy, format: :js, params: params
              end.to change { ProposalAdhesion.count }.by(-1)

              expect(ProposalAdhesion.count).to eq(0)
            end
          end
          context "when adhesions are disabled" do
            let(:feature) do
              create(:proposal_feature, :with_adhesions_disabled)
            end

            it "does not delete the adhesion" do
              expect do
                delete :destroy, format: :js, params: params
              end.not_to change { ProposalAdhesion.count }

              expect(flash[:alert]).not_to be_empty
              expect(response).to have_http_status(302)
            end
          end
        end
      end

      #
      # Identity adhesions combinations
      #
      describe "When user has some of its user_groups adhered" do
        let(:feature) do
          create(:proposal_feature, :with_adhesions_enabled)
        end
        let(:adhered_groups) { [] }
        let(:unadhered_groups) { [] }

        context "when user has no user_groups" do
          it "returns only an adhere button for the user" do
            get :identities, params: params

            expect(response).to have_http_status(:ok)
            expect(subject).to render_template("decidim/proposals/proposal_adhesions/identities")
          end
        end
        context "when all user user_groups are adhered" do
          it "offers user_groups to unahere" do
            create_adhered_groups

            get :identities, params: params

            expect(response).to have_http_status(:ok)
            expect(assigns[:to_adhere_groups]).to be_empty
            expect(assigns[:to_unadhere_groups]).to eq(adhered_groups)
            expect(subject).to render_template("decidim/proposals/proposal_adhesions/identities")
          end
        end
        context "when half user organizations are adhered" do
          it "offers the corresponding action to each organization" do
            create_adhered_groups
            create_unadhered_groups

            get :identities, params: params

            expect(response).to have_http_status(:ok)
            expect(assigns[:to_adhere_groups]).to eq(unadhered_groups)
            expect(assigns[:to_unadhere_groups]).to eq(adhered_groups)
            expect(subject).to render_template("decidim/proposals/proposal_adhesions/identities")
          end
        end
        context "when none of user's user_groups are adhered" do
          it "offers all user_groups to adhere" do
            create_unadhered_groups

            get :identities, params: params

            expect(response).to have_http_status(:ok)
            expect(assigns[:to_adhere_groups]).to eq(unadhered_groups)
            expect(assigns[:to_unadhere_groups]).to be_empty
            expect(subject).to render_template("decidim/proposals/proposal_adhesions/identities")
          end
        end
      end

      #
      # ÚTIL METHODS
      #
      def create_adhered_groups
        2.times do
          adh = create(:organization_proposal_adhesion,
                       proposal: proposal, author: user)
          ug = adh.user_group
          ug.verified_at = DateTime.current
          adhered_groups << ug.id
        end
        user.save!
      end

      def create_unadhered_groups
        2.times do
          ug = create(:user_group, verified_at: DateTime.current)
          user.user_groups << ug
          unadhered_groups << ug.id
        end
        user.save!
      end
    end
  end
end
