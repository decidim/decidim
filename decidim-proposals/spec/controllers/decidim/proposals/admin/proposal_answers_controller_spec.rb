# frozen_string_literal: true

require "spec_helper"
require "decidim/templates/test/factories"

describe Decidim::Proposals::Admin::ProposalAnswersController do
  routes { Decidim::Proposals::AdminEngine.routes }

  let(:user) { create(:user, :confirmed, :admin, organization: component.organization) }
  let(:component) { create(:proposal_component, :with_creation_enabled, :with_attachments_allowed) }
  let(:proposal) { create(:proposal, component:) }
  let(:proposal_state) { create(:proposal_state, component:) }
  let(:template) { create(:template, target: :proposal_answer, templatable: component, field_values: { "proposal_state_id" => proposal_state.id }) }
  let(:form_double) { Decidim::Proposals::Admin::ProposalAnswerForm.from_params({}) }

  before do
    sign_in user
    request.env["decidim.current_organization"] = component.organization
    request.env["decidim.current_component"] = component

    allow(Decidim::Proposals::Admin::ProposalAnswerForm).to receive(:from_params).and_return(form_double)
    allow(form_double).to receive(:with_context).and_return(form_double)
  end

  describe "POST update_multiple_answers" do
    let(:proposal_ids) { [proposal.id] }
    let(:multiple_params) { { proposal_ids:, template: { template_id: template.id } } }

    before do
      component.update!(
        settings: { answers_with_costs: true }
      )

      allow(controller).to receive(:proposals_path).and_return("/proposals")
      allow(form_double).to receive(:attributes).and_return({ "answer" => "Test answer" })
    end

    it "enqueues ProposalAnswerJob for each proposal and redirects" do
      allow(form_double).to receive(:costs_required?).and_return(false)

      expect {
        post :update_multiple_answers, params: multiple_params
      }.to have_enqueued_job(Decidim::Proposals::Admin::ProposalAnswerJob).with(proposal.id, anything, component)

      expect(response).to redirect_to(Decidim::EngineRouter.admin_proxy(component).root_path)
      expect(flash[:notice]).to eq(I18n.t("proposals.answer.success", scope: "decidim.proposals.admin"))
    end

    context "when cost data is required" do
      before do
        allow(form_double).to receive(:costs_required?).and_return(true)
        proposal.update!(cost: nil)
      end

      it "redirects with an alert" do
        post :update_multiple_answers, params: multiple_params

        expect(response).to redirect_to(Decidim::EngineRouter.admin_proxy(component).root_path)
        expect(flash[:alert]).to eq(I18n.t("proposals.answer.missing_cost_data", scope: "decidim.proposals.admin"))
      end
    end

    context "when cost data is not required" do
      before do
        allow(form_double).to receive(:costs_required?).and_return(false)
      end

      it "enqueues ProposalAnswerJob for each proposal and redirects without checking cost data" do
        expect {
          post :update_multiple_answers, params: multiple_params
        }.to have_enqueued_job(Decidim::Proposals::Admin::ProposalAnswerJob).with(proposal.id, anything, component)

        expect(response).to redirect_to(Decidim::EngineRouter.admin_proxy(component).root_path)
        expect(flash[:notice]).to eq(I18n.t("proposals.answer.success", scope: "decidim.proposals.admin"))
      end
    end
  end
end
