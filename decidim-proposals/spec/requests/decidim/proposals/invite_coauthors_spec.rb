# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe "Invite coauthors" do
      let(:component) { create(:proposal_component) }
      let(:organization) { component.organization }
      let(:proposal) { create(:proposal, component:) }
      let(:user) { create(:user, :confirmed, organization:) }
      let(:other_organization_user) { create(:user, :confirmed, organization: create(:organization)) }
      let(:path) { Decidim::EngineRouter.main_proxy(component).proposal_invite_coauthors_path(proposal_id: proposal.id) }

      before do
        login_as user, scope: :user
      end

      it "does not allow inviting a user from another organization" do
        post path, params: { id: other_organization_user.id }, headers: { "HOST" => organization.host }

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
