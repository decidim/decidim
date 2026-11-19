# frozen_string_literal: true

require "spec_helper"

describe "Admin authorization revocations" do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:message) { I18n.t("authorization_revocation.destroy_nok", scope: "decidim.admin.menu") }

  before do
    host! organization.host
    login_as user, scope: :user
  end

  describe "POST destroy_before_date" do
    context "without a date" do
      it "shows the alert on the authorization workflows page" do
        post(decidim_verifications.admin_verifications_destroy_before_date_path, params: { revocations_before_date: { before_date: "" } })

        expect(response).to redirect_to(decidim_admin.authorization_workflows_url(host: organization.host))
        follow_redirect!

        expect(response.body).to include(message)
      end
    end
  end

  describe "DELETE destroy_all" do
    context "when the authorizations cannot be revoked" do
      before do
        stub_command_broadcast(Decidim::Verifications::RevokeAllAuthorizations, :invalid)
      end

      it "shows the alert on the authorization workflows page" do
        delete(decidim_verifications.admin_verifications_destroy_all_path)

        expect(response).to redirect_to(decidim_admin.authorization_workflows_url(host: organization.host))
        follow_redirect!

        expect(response.body).to include(message)
      end
    end
  end
end
