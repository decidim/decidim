# frozen_string_literal: true

require "spec_helper"

describe "Admin evaluation assignments" do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:participatory_process) { create(:participatory_process, organization:) }
  let(:component) { create(:proposal_component, participatory_space: participatory_process) }
  let(:proposals_path) { Decidim::EngineRouter.admin_proxy(component).root_path }

  before do
    host! organization.host
    login_as user, scope: :user
  end

  describe "POST create" do
    context "when no proposals or evaluators are selected" do
      it "shows the alert on the proposals page" do
        post(Decidim::EngineRouter.admin_proxy(component).evaluation_assignment_path, params: { proposal_ids: [], evaluator_role_ids: [] })

        expect(response).to redirect_to(proposals_path)
        follow_redirect!

        expect(response.body).to include(I18n.t("evaluation_assignments.create.invalid", scope: "decidim.proposals.admin"))
      end
    end
  end
end
