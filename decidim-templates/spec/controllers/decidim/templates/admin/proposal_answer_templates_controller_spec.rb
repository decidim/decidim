# frozen_string_literal: true

require "spec_helper"

describe Decidim::Templates::Admin::ProposalAnswerTemplatesController do
  routes { Decidim::Templates::AdminEngine.routes }

  let(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, :admin, organization:) }
  let(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
  let(:component) { create(:proposal_component, participatory_space: participatory_process) }

  let(:other_org) { create(:organization) }
  let(:other_user) { create(:user, :confirmed, :admin, organization: other_org) }
  let(:other_process) { create(:participatory_process, :with_steps, organization: other_org) }
  let(:other_component) { create(:proposal_component, participatory_space: other_process) }

  before do
    request.env["decidim.current_organization"] = organization
    sign_in user, scope: :user
  end

  describe "helper available_states" do
    let!(:state) { create(:proposal_state, component:) }
    let!(:other_state) { create(:proposal_state, component: other_component) }

    it "returns states for the given component" do
      states = controller.helpers.available_states(component.id)
      expect(states).to include(state)
    end

    it "returns states for a cross-org component (inline-disable: caller is responsible for scoping)" do
      states = controller.helpers.available_states(other_component.id)
      expect(states).to include(other_state)
    end
  end

  describe "helper availability_options_for_select" do
    it "includes only components from the current organization" do
      _own_component = component
      _other_component = other_component
      ids = controller.helpers.availability_options_for_select.map(&:last)
      expect(ids).to include(component.id)
      expect(ids).not_to include(other_component.id)
    end
  end

  describe "helper proposal_state" do
    let(:template) do
      create(:template, organization:, target: :proposal_answer, templatable: component,
                        field_values: { "proposal_state_id" => state.id })
    end
    let!(:state) { create(:proposal_state, component:) }

    it "returns the state title" do
      expect(controller.helpers.proposal_state(template)).to eq(translated_attribute(state.title))
    end
  end

  describe "private template method" do
    let!(:own_template) { create(:template, organization:, target: :proposal_answer) }
    let!(:other_template) { create(:template, organization: other_org, target: :proposal_answer) }

    it "finds own template by id" do
      controller.params = { id: own_template.id }
      expect(controller.send(:template)).to eq(own_template)
    end

    it "returns nil for a cross-org template id" do
      controller.params = { id: other_template.id }
      expect(controller.send(:template)).to be_nil
    end
  end

  describe "private proposal method" do
    let!(:own_proposal) { create(:proposal, component:) }
    let!(:other_proposal) { create(:proposal, component: other_component) }

    it "finds own proposal by id" do
      controller.params = { proposalId: own_proposal.id.to_s }
      expect(controller.send(:proposal)).to eq(own_proposal)
    end

    it "returns nil for a cross-org proposal id" do
      controller.params = { proposalId: other_proposal.id.to_s }
      expect(controller.send(:proposal)).to be_nil
    end
  end

  describe "GET fetch" do
    let(:template) do
      create(:template, organization:, target: :proposal_answer, templatable: component,
                        field_values: { "proposal_state_id" => state.id })
    end
    let!(:state) { create(:proposal_state, component:) }
    let!(:proposal) { create(:proposal, component:) }

    context "without proposalId" do
      it "returns an error" do
        get :fetch, params: { id: template.id, format: :json }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "with a cross-org template id" do
      let(:other_template) { create(:template, organization: other_org, target: :proposal_answer) }

      it "returns an error" do
        get :fetch, params: { id: other_template.id, proposalId: proposal.id, format: :json }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "with a cross-org proposalId" do
      let(:other_proposal) { create(:proposal, component: other_component) }

      it "returns an error" do
        get :fetch, params: { id: template.id, proposalId: other_proposal.id, format: :json }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "with own template and proposal" do
      it "returns the response" do
        get :fetch, params: { id: template.id, proposalId: proposal.id, format: :json }
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
