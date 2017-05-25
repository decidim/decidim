# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe ProposalAnswersController, type: :controller do
        let(:feature) { proposal.feature }
        let(:proposal) { create(:proposal) }
        let(:user) { create(:user, :confirmed, :admin, organization: feature.organization) }

        routes do
          Decidim::Proposals::AdminEngine.routes
        end

        before do
          @request.env["decidim.current_organization"] = feature.organization
          @request.env["decidim.current_participatory_process"] = feature.participatory_process
          @request.env["decidim.current_feature"] = feature
          sign_in user
        end

        let(:params) do
          {
            id: proposal.id,
            proposal_id: proposal.id,
            feature_id: feature.id,
            participatory_process_id: feature.participatory_process.id,
            state: "rejected"
          }
        end

        describe "PUT update" do
          context "when the command fails" do
            it "renders the edit template" do
              put :update, params: params

              expect(response).to render_template(:edit)
            end
          end
        end
      end
    end
  end
end
