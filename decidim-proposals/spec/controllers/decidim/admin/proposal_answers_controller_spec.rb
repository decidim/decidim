# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe ProposalAnswersController, type: :controller do
        routes { Decidim::Proposals::AdminEngine.routes }

        let(:feature) { proposal.feature }
        let(:proposal) { create(:proposal) }
        let(:user) { create(:user, :confirmed, :admin, organization: feature.organization) }

        let(:params) do
          {
            id: proposal.id,
            proposal_id: proposal.id,
            feature_id: feature.id,
            participatory_process_slug: feature.participatory_space.slug,
            state: "rejected"
          }
        end

        before do
          request.env["decidim.current_organization"] = feature.organization
          request.env["decidim.current_feature"] = feature
          sign_in user
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
