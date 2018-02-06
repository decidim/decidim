# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe ProposalsController, type: :controller do
      routes { Decidim::Proposals::Engine.routes }

      let(:user) { create(:user, :confirmed, organization: feature.organization) }

      let(:params) do
        {
          feature_id: feature.id
        }
      end

      before do
        request.env["decidim.current_organization"] = feature.organization
        request.env["decidim.current_participatory_space"] = feature.participatory_space
        request.env["decidim.current_feature"] = feature
        sign_in user
      end

      describe "POST create" do
        context "when creation is not enabled" do
          let(:feature) { create(:proposal_feature) }

          it "raises an error" do
            post :create, params: params

            expect(flash[:alert]).not_to be_empty
          end
        end

        context "when creation is enabled" do
          let(:feature) { create(:proposal_feature, :with_creation_enabled) }

          it "creates a proposal" do
            post :create, params: params.merge(
              title: "Lorem ipsum dolor sit amet, consectetur adipiscing elit",
              body: "Ut sed dolor vitae purus volutpat venenatis. Donec sit amet sagittis sapien. Curabitur rhoncus ullamcorper feugiat. Aliquam et magna metus."
            )

            expect(flash[:notice]).not_to be_empty
            expect(response).to have_http_status(302)
          end
        end
      end

      describe "withdraw a proposal" do
        let(:feature) { create(:proposal_feature, :with_creation_enabled) }

        context "when an authorized user is withdrawing a proposal" do
          let(:proposal) { create(:proposal, feature: feature, author: user) }

          it "withdraws the proposal" do
            put :withdraw, params: params.merge(id: proposal.id)

            expect(flash[:notice]).not_to be_empty
            expect(response).to have_http_status(302)
          end
        end

        describe "when current user is NOT the author of the proposal" do
          let(:current_user) { create(:user, organization: feature.organization) }
          let(:proposal) { create(:proposal, feature: feature, author: current_user) }

          context "and the proposal has no supports" do
            it "is not able to withdraw the proposal" do
              expect(WithdrawProposal).not_to receive(:call)

              put :withdraw, params: params.merge(id: proposal.id)

              expect(flash[:alert]).not_to be_empty
              expect(response).to have_http_status(302)
            end
          end
        end
      end
    end
  end
end
