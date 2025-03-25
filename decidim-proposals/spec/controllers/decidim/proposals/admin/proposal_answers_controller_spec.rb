# frozen_string_literal: true

require "spec_helper"
require "decidim/templates/test/factories"

module Decidim
  module Proposals
    module Admin
      describe ProposalAnswersController do
        include Decidim::ApplicationHelper

        let(:user) { create(:user, :confirmed, :admin, organization: component.organization) }
        let(:component) { create(:proposal_component, :with_creation_enabled, :with_attachments_allowed) }
        let!(:emendation) { create(:proposal, component:) }
        let!(:amendment) { create(:amendment, amendable: proposal2, emendation:) }
        let(:proposal1) { create(:proposal, cost: nil, component:, proposal_state: nil) }
        let(:proposal2) { create(:proposal, cost: nil, component:, proposal_state: nil) }
        let(:proposal_state) { create(:proposal_state, component:) }
        let(:template) { create(:template, skip_injection: true, target: :proposal_answer, templatable: component, field_values: { "proposal_state_id" => proposal_state.id }) }
        let(:proposal_ids) { [proposal1.id, proposal2.id] }
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
                post :update, params: params
                expect(response).to have_http_status(:found)
                expect(subject).to redirect_to(proposals_path)
              end
            end
          end
        end

        describe "POST update_multiple_answers" do
          it "enqueues ProposalAnswerJob for each proposal and redirects" do
            expect { post :update_multiple_answers, params: }.to have_enqueued_job(ProposalAnswerJob).exactly(2).times

            expect(response).to redirect_to(Decidim::EngineRouter.admin_proxy(component).root_path)
            expect(flash[:notice]).to include("2 proposals will be answered using the template \"#{template.name["en"]}\".")
            expect(flash[:alert]).to be_nil
          end

          context "when some proposal fails" do
            before do
              valid = false
              # rubocop:disable RSpec/AnyInstance
              allow_any_instance_of(Decidim::Proposals::Admin::ProposalAnswerForm).to receive(:valid?) do |_arg|
                valid = !valid
              end
              # rubocop:enable RSpec/AnyInstance
            end

            it "enqueues ProposalAnswerJob once and redirects" do
              expect { post :update_multiple_answers, params: }.to have_enqueued_job(ProposalAnswerJob).exactly(1).times

              expect(response).to redirect_to(Decidim::EngineRouter.admin_proxy(component).root_path)
              expect(flash[:notice]).to include("1 proposals will be answered using the template \"#{template.name["en"]}\".")
              expect(flash[:alert]).to include("could not be answered due errors applying the template \"#{template.name["en"]}\".")
            end
          end

          context "when proposal is an emendation" do
            let(:proposal1) { emendation }

            it "enqueues ProposalAnswerJob once and redirects" do
              expect { post :update_multiple_answers, params: }.to have_enqueued_job(ProposalAnswerJob).exactly(1).times

              expect(response).to redirect_to(Decidim::EngineRouter.admin_proxy(component).root_path)
              expect(flash[:notice]).to include("1 proposals will be answered using the template \"#{template.name["en"]}\".")
              expect(flash[:alert]).to include("Proposals with IDs [#{proposal1.id}] could not be answered due errors applying the template \"#{template.name["en"]}\".")
            end
          end

          context "when cost is not required" do
            before do
              component.update!(
                step_settings: {
                  component.participatory_space.active_step.id => {
                    answers_with_costs: true
                  }
                }
              )
            end

            it "redirects without an alert" do
              expect { post :update_multiple_answers, params: }.to have_enqueued_job(ProposalAnswerJob).exactly(2).times

              expect(response).to redirect_to(Decidim::EngineRouter.admin_proxy(component).root_path)
              expect(flash[:notice]).to include("proposals will be answered using the template \"#{template.name["en"]}\".")
              expect(flash[:alert]).to be_nil
            end
          end

          context "when templates is not installed" do
            before do
              allow(Decidim).to receive(:module_installed?).and_call_original
              allow(Decidim).to receive(:module_installed?).with(:templates).and_return(false)
            end

            it "redirects with an alert" do
              expect { post :update_multiple_answers, params: }.not_to have_enqueued_job(ProposalAnswerJob)

              expect(response).to redirect_to(Decidim::EngineRouter.admin_proxy(component).root_path)
              expect(flash[:alert]).to include("could not be answered due errors")
              expect(flash[:notice]).to be_nil
            end
          end
        end
      end
    end
  end
end
