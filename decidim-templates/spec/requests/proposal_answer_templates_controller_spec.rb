# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Proposal answer templates fetch" do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
  let(:component) { create(:proposal_component, participatory_space: participatory_process) }
  let!(:template) { create(:template, organization:, target: :proposal_answer, templatable: component) }

  let(:request_headers) { { "HOST" => organization.host } }
  let(:path) { "/en/admin/templates/proposal_answer_templates/fetch" }

  before do
    login_as user, scope: :user
  end

  context "when proposalId is missing" do
    it "returns the unprocessable_content JSON response" do
      get path, params: { id: template.id, format: :json }, headers: request_headers

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["msg"]).to eq(I18n.t("templates.fetch.error", scope: "decidim.admin"))
    end
  end

  context "with own template and proposal" do
    let!(:proposal) { create(:proposal, component:) }
    let!(:state) { create(:proposal_state, component:) }
    let(:template) do
      create(:template, organization:, target: :proposal_answer, templatable: component,
                        field_values: { "proposal_state_id" => state.id })
    end

    it "returns the proposal state and interpolated template" do
      get path, params: { id: template.id, proposalId: proposal.id, format: :json }, headers: request_headers

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["state"]).to eq(state.token)
    end
  end
end
