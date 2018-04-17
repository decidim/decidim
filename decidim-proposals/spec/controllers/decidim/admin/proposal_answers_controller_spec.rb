# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe ProposalAnswersController, type: :controller do
        routes { Decidim::Proposals::AdminEngine.routes }

        let(:component) { proposal.component }
        let(:proposal) { create(:proposal) }
        let(:user) { create(:user, :confirmed, :admin, organization: component.organization) }

        let(:params) do
          {
            id: proposal.id,
            proposal_id: proposal.id,
            component_id: component.id,
            participatory_process_slug: component.participatory_space.slug,
            state: "rejected"
          }
        end

        before do
          request.env["decidim.current_organization"] = component.organization
          request.env["decidim.current_component"] = component
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
