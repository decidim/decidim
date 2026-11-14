# frozen_string_literal: true

require "spec_helper"

describe "OAuth applications" do
  let(:admin) { create(:admin) }
  let!(:oauth_application) { create(:oauth_application) }

  before do
    login_as admin, scope: :admin
  end

  describe "DELETE destroy" do
    context "when the application cannot be deleted" do
      before do
        stub_command_broadcast(Decidim::System::DestroyOAuthApplication, :invalid)
      end

      it "shows the error on the applications page" do
        delete(decidim_system.oauth_application_path(oauth_application))

        expect(response).to redirect_to(decidim_system.oauth_applications_path)
        follow_redirect!

        expect(response.body).to include(I18n.t("oauth_applications.destroy.error", scope: "decidim.system"))
      end
    end
  end
end
