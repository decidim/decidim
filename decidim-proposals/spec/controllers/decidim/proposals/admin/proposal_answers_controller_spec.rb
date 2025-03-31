# frozen_string_literal: true

require "spec_helper"
require "decidim/templates/test/factories"

module Decidim
  module Proposals
    module Admin
      describe ProposalAnswersController do
        routes { Decidim::Proposals::AdminEngine.routes }

        include Decidim::ApplicationHelper

        let(:user) { create(:user, :confirmed, :admin, organization: component.organization) }
        let(:component) { create(:proposal_component, :with_creation_enabled, :with_attachments_allowed) }
        let!(:emendation) { create(:proposal, component:) }
        let!(:amendment) { create(:amendment, amendable: proposal2, emendation:) }
        let(:proposal1) { create(:proposal, cost: nil, component:, proposal_state: nil) }
        let(:proposal2) { create(:proposal, cost: nil, component:, proposal_state: nil) }
        let(:proposal_state) { create(:proposal_state, component:) }
        let(:template) { create(:template, skip_injection: true, target: :proposal_answer, templatable: component, field_values: { "proposal_state_id" => proposal_state.id }) }
        let!(:proposal_ids) { [proposal1.id, proposal2.id] }
        let(:params) do
          {
            proposal_ids:, template: { template_id: template.id }
          }
        end
        let(:context) do
          {
            current_organization: component.organization,
            current_participatory_space: component.participatory_space,
            current_component: component,
            current_user: user
          }
        end

        before do
          sign_in user
          request.env["decidim.current_organization"] = component.organization
          request.env["decidim.current_participatory_space"] = component.participatory_space
          request.env["decidim.current_component"] = component
        end

        describe "PUT update" do
          let(:proposals_path) { "decidim/proposals/admin/proposals/index" }
          let(:params) do
            {
              id: proposal1.id,
              internal_state: "accepted",
              component_id: component.id,
              proposal_id: proposal1.id,
              participatory_process_slug: component.participatory_space.slug
            }
          end

          context "when costs are enabled" do
            before do
              component.update!(
                step_settings: {
                  component.participatory_space.active_step.id => {
                    answers_with_costs: true
                  }
                }
              )
              allow(controller).to receive(:proposals_path).and_return(proposals_path)
            end

            context "when the update is successful." do
              it "renders ProposalsAdmin#index view" do
                put(:update, params:)
                expect(response).to have_http_status(:found)
                expect(subject).to redirect_to(proposals_path)
              end
            end
          end
        end
      end
    end
  end
end
