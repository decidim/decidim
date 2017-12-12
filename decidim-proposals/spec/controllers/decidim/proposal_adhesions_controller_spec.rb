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

      describe 'As User' do
        context "when adhesions are enabled" do
          let(:feature) do
            create(:proposal_feature, :with_adhesions_enabled)
          end

          it "should allow adheering" do
            expect do
              post :create, format: :js, params: params
            end.to change { ProposalAdhesion.count }.by(1)

            expect(ProposalAdhesion.last.author).to eq(user)
            expect(ProposalAdhesion.last.proposal).to eq(proposal)
          end
        end

        context "when adhesions are disabled" do
          let(:feature) do
            create(:proposal_feature, :with_adhesions_disabled)
          end

          it "should not allow adheering" do
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

          it "should not allow adheering" do
            expect do
              post :create, format: :js, params: params
            end.not_to change { ProposalAdhesion.count }

            expect(flash[:alert]).not_to be_empty
            expect(response).to have_http_status(302)
          end
        end
      end
      describe 'As User unadheering a Proposal' do
        before do
          create(:proposal_adhesion, proposal: proposal, author: user)
        end
        context "when adhesions are enabled" do
          let(:feature) do
            create(:proposal_feature, :with_adhesions_enabled)
          end

          it "should delete the adhesion" do
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

          it "should not delete the adhesion" do
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
      describe 'As Organization' do
        let(:user_group) { create(:user_group, verified_at: DateTime.now) }
        before do
          create(:user_group_membership, user: user, user_group: user_group)
          params[:user_group_id]= user_group.id
        end
        describe 'adheering a Proposal' do
          context "when adhesions are enabled" do
            let(:feature) do
              create(:proposal_feature, :with_adhesions_enabled)
            end

            it "should allow adheering" do
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

            it "should not allow adheering" do
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

            it "should not allow adheering" do
              expect do
                post :create, format: :js, params: params
              end.not_to change { ProposalAdhesion.count }

              expect(flash[:alert]).not_to be_empty
              expect(response).to have_http_status(302)
            end
          end
        end
        describe 'As User unadheering a Proposal' do
          before do
            create(:proposal_adhesion, proposal: proposal, author: user, user_group: user_group)
          end
          context "when adhesions are enabled" do
            let(:feature) do
              create(:proposal_feature, :with_adhesions_enabled)
            end

            it "should delete the adhesion" do
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

            it "should not delete the adhesion" do
              expect do
                delete :destroy, format: :js, params: params
              end.not_to change { ProposalAdhesion.count }

              expect(flash[:alert]).not_to be_empty
              expect(response).to have_http_status(302)
            end
          end
        end
      end

    end
  end
end
