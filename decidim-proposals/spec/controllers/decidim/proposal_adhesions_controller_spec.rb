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

      describe "POST create" do
        context "with adhesions enabled" do
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
        end

        context "with adhesions disabled" do
          let(:feature) do
            create(:proposal_feature)
          end

          it "doesn't allow adheering" do
            expect do
              post :create, format: :js, params: params
            end.not_to change { ProposalAdhesion.count }

            expect(flash[:alert]).not_to be_empty
            expect(response).to have_http_status(302)
          end
        end

        context "with adhesions enabled but adhesions blocked" do
          let(:feature) do
            create(:proposal_feature, :with_adhesions_blocked)
          end

          it "doesn't allow adheering" do
            expect do
              post :create, format: :js, params: params
            end.not_to change { ProposalAdhesion.count }

            expect(flash[:alert]).not_to be_empty
            expect(response).to have_http_status(302)
          end
        end
      end

      describe "destroy" do
        before do
          create(:proposal_adhesion, proposal: proposal, author: user)
        end
        context "with adhesions enabled" do
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
        context "with adhesions disabled" do
          let(:feature) do
            create(:proposal_feature, :with_adhesions_disabled)
          end

          it "adhesion should not be deleted" do
            expect do
              delete :destroy, format: :js, params: params
            end.to change { ProposalAdhesion.count }.by(-1)

            expect(ProposalAdhesion.count).to eq(0)
          end
        end

      end
    end
  end
end
